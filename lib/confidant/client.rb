require 'json'
require 'base64'
require 'aws-sdk-core'
require 'rest-client'

module Confidant
  # The Confidant Client implementation
  class Client
    TOKEN_SKEW_SECONDS = 3 * 60
    TIME_FORMAT = '%Y%m%dT%H%M%SZ'.freeze

    def initialize(config = Confidant::Configurator.config)
      @config = config
      @kms = Aws::KMS::Client.new(region: config[:region])
      @suppress_errors = false
    end

    # Return a Hash of credentials from the confidant API
    # for +service+, either explicitly-provided, or from config.
    def get_service(service = nil)
      target_service = service_name(service)
      url = format('%s/v1/services/%s', @config[:url], target_service)
      password = generate_token

      log.debug "Requesting #{url} as user #{api_user}"
      response = RestClient::Request.execute(
        method: :get,
        url: url,
        user: api_user,
        password: password
      )

      JSON.parse(response.body)
    rescue => ex
      Confidant.log_exception(self, ex)
      return { result: false } if @suppress_errors
      raise unless @suppress_errors
    end

    # Return the name of the service for which we
    # should fetch credentials from the confidant API.
    # Returns +service+ if provided, or the config
    # value at @config[:get_service][:service]
    # Raises +ConfigurationError+ if no service was
    # provided or configured.
    def service_name(service = nil)
      return service unless service.nil?
      if @config[:get_service] && @config[:get_service][:service]
        return @config[:get_service][:service]
      end
      raise 'Service name must be specifid, or provided in config as ' \
            '{get_service => service}' if service.nil?
    end

    # Return the name of the user that will connect to the confidant API
    # TODO(v1-auth-support): Support v1-style user names.
    def api_user
      format(
        '%s/%s/%s',
        @config[:token_version],
        @config[:user_type],
        @config[:from]
      )
    end

    # The Python client suppresses all errors,
    # returning { result: false } instead.
    # Toggle this behavior if called from the CLI.
    def suppress_errors(enable = true)
      @suppress_errors = enable
      true
    end

    # Return an auth token for the confidant service,
    # encrypted via KMS.
    def generate_token
      # TODO(v1-auth-support): Handle the different encryption_context
      if @config[:token_version].to_i != 2
        raise 'This client only supports KMS v2 auth tokens.'
      end

      now = Time.now.utc
      payload = {
        not_before: (now - TOKEN_SKEW_SECONDS).strftime(TIME_FORMAT),
        not_after: (now - TOKEN_SKEW_SECONDS +
          (@config[:token_lifetime].to_i * 60)).strftime(TIME_FORMAT)
      }.to_json

      encrypt_params = {
        key_id: @config[:auth_key],
        plaintext: payload,
        encryption_context: {
          to: @config[:to],
          from: @config[:from],
          user_type: @config[:user_type]
        }
      }

      log.debug "Asking KMS to encrypt: #{encrypt_params}"
      resp = @kms.encrypt(encrypt_params)

      Base64.strict_encode64(resp.ciphertext_blob)
    end
  end
end
