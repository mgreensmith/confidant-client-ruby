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
      log.debug "Requesting #{api_service_url(service_name(service))} " \
                "as user #{api_user}"
      response = RestClient::Request.execute(
        method: :get,
        url: api_service_url(service_name(service)),
        user: api_user,
        password: generate_token,
        headers: {
          user_agent: RestClient::Platform.default_user_agent.prepend(
            "confidant-client/#{Confidant::VERSION} "
          )
        }
      )

      JSON.parse(response.body)
    rescue => ex
      Confidant.log_exception(self, ex)
      @suppress_errors ? api_error_response : raise
    end

    # The Python client suppresses API errors,
    # returning { result: false } instead.
    # Mimic this behavior based on the truthiness of +enable+.
    # This is generally only called from Confidant::CLI
    def suppress_errors(enable = true)
      @suppress_errors = enable
      true
    end

    private

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
      raise 'Service name must be specified, or provided in config as ' \
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

    # The URL to get credentials for +service+ from the Confidant server.
    def api_service_url(service)
      format('%s/v1/services/%s', @config[:url], service)
    end

    # The falsey response to return when
    # @suppress_errors is true,
    # rather than raising exceptions.
    def api_error_response
      { 'result' => 'false' }
    end

    # The content of a confidant auth token payload,
    # to be encrypted by KMS.
    def token_payload
      now = Time.now.utc

      start_time = (now - TOKEN_SKEW_SECONDS)

      end_time = (
        now - TOKEN_SKEW_SECONDS +
        (@config[:token_lifetime].to_i * 60)
      )

      { not_before: start_time.strftime(TIME_FORMAT),
        not_after: end_time.strftime(TIME_FORMAT)
      }.to_json
    end

    # Return an auth token for the confidant service,
    # encrypted via KMS.
    def generate_token
      # TODO(v1-auth-support): Handle the different encryption_context
      if @config[:token_version].to_i != 2
        raise 'This client only supports KMS v2 auth tokens.'
      end

      encrypt_params = {
        key_id: @config[:auth_key],
        plaintext: token_payload,
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
