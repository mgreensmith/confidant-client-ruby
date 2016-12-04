require 'spec_helper'

describe Confidant::Client do
  before do
    Logging.logger.root.appenders = nil

    config = {
      user_type: 'philosopher',
      from: 'hypatia',
      to: 'aedesia',
      region: 'alexandria',
      auth_key: 'astrolabe',
      url: 'athens',
      token_version: 2
    }

    @client = Confidant::Client.new(Confidant::Configurator.new(config))

    allow(RestClient::Platform)
      .to receive(:default_user_agent).and_return('sextant')

    stub_const('Confidant::VERSION', '999')
  end

  context '#get_service' do
    before do
      allow_any_instance_of(Confidant::Client)
        .to receive(:generate_token).and_return('tympan')
    end

    it 'can get credentials for a service from the API' do
      allow_any_instance_of(Confidant::Client)
        .to receive(:generate_token).and_return('tympan')

      api_response = double
      expect(api_response).to receive(:body).and_return('{ "hello": "world" }')

      expect(RestClient::Request).to receive(:execute).with(
        method: :get,
        url: 'athens/v1/services/oracle',
        user: '2/philosopher/hypatia',
        password: 'tympan',
        headers: { user_agent: 'confidant-client/999 sextant' }
      ).and_return(api_response)

      expect(@client.get_service('oracle')).to eq('hello' => 'world')
    end

    it 'does not suppress errors by default' do
      expect(RestClient::Request).to receive(:execute).and_raise(StandardError)
      expect { @client.get_service('oracle') }.to raise_error(StandardError)
    end

    it 'suppresses errors if @suppress_errors is true' do
      expect(RestClient::Request).to receive(:execute).and_raise(StandardError)
      @client.suppress_errors
      expect(@client.get_service('oracle')).to eq('result' => 'false')
    end
  end

  context '#generate_token' do
    it 'can generate a v2 auth token' do
      kms_response = double
      expect(kms_response).to receive(:ciphertext_blob).and_return('12345')

      allow_any_instance_of(Aws::KMS::Client)
        .to receive(:encrypt).and_return(kms_response)

      # Expect Bas64-encoded :ciphertext_blob
      expect(@client.send(:generate_token)).to eq('MTIzNDU=')
    end

    it 'raises if a v1 token is requested' do
      @client.config[:token_version] = 1
      expect { @client.send(:generate_token) }
        .to raise_error(Confidant::ConfigurationError)
    end
  end

  context '#service_name' do
    it 'returns a provided service name from parameter' do
      @client.config[:get_service] = { service: 'aristotle' }
      expect(@client.send(:service_name, 'plato')).to eq('plato')
      expect(@client.send(:service_name)).to eq('aristotle')
    end

    it 'raises if a service name was not provided or configured' do
      expect { @client.send(:service_name) }
        .to raise_error(Confidant::ConfigurationError)
    end
  end
end
