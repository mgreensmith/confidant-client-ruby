require 'spec_helper'

describe Confidant::Client do
  before do
    Logging.logger.root.appenders = nil

    @client = Confidant::Client.new(
      user_type: 'philosopher',
      from: 'hypatia',
      to: 'aedesia',
      region: 'alexandria',
      auth_key: 'astrolabe',
      url: 'athens',
      token_version: 2
    )

    allow_any_instance_of(Confidant::Client)
      .to receive(:generate_token).and_return('tympan')

    allow(RestClient::Platform)
      .to receive(:default_user_agent).and_return('sextant')

    stub_const('Confidant::VERSION', '999')

    @api_response = double
  end

  it '#get_service can get credentials for a service from the API' do
    expect(@api_response).to receive(:body).and_return('{ "hello": "world" }')

    expect(RestClient::Request).to receive(:execute).with(
      method: :get,
      url: 'athens/v1/services/oracle',
      user: '2/philosopher/hypatia',
      password: 'tympan',
      headers: { user_agent: 'confidant-client/999 sextant' }
    ).and_return(@api_response)

    expect(@client.get_service('oracle')).to eq('hello' => 'world')
  end

  context 'error-handling' do
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
end
