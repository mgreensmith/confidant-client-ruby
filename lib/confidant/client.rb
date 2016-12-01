require 'json'
require 'base64'
require 'aws-sdk-core'
require 'rest-client'

module Confidant
  # The Confidant Client implementaiton
  class Client
    TOKEN_SKEW_SECONDS = 3 * 60
    TIME_FORMAT = '%Y%m%dT%H%M%SZ'.freeze

    def initialize(config)
      @config = config
      @kms = Aws::KMS::Client.new(region: config[:region])
    end

    def get_service # rubocop:disable Style/AccessorMethodName
      user = format('%s/%s/%s', @config[:token_version], @config[:user_type], @config[:from])
      url = format('%s/v1/services/%s', @config[:url], @config[:get_service][:service])
      password = generate_token

      log.debug "Requesting #{url} as user #{user}"
      resp = RestClient::Request.execute(
        method: :get,
        url: url,
        user: user,
        password: password
      )

      puts resp.body
      true

    rescue
      resp = { result: false }.to_json
      puts resp
      false
    end

    def generate_token
      raise 'This client only supports KMS v2 auth tokens.' if @config[:token_version].to_i != 2

      now = Time.now.utc

      start_time = now - TOKEN_SKEW_SECONDS
      not_before = start_time.strftime(TIME_FORMAT)

      end_time = start_time + (@config[:token_lifetime].to_i * 60)
      not_after = end_time.strftime(TIME_FORMAT)

      payload = { not_before: not_before, not_after: not_after }.to_json

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

      log.debug "Encrypted KMS data: #{Base64.strict_encode64(resp.ciphertext_blob)}"

      Base64.strict_encode64(resp.ciphertext_blob)
    end
  end
end
