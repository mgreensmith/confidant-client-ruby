require 'spec_helper'

describe Confidant::CLI do
  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
    Loggability.output_to($stderr)
  end

  after(:all) do
    $stdout = STDOUT
    $stderr = STDERR
  end

  it 'logs errors' do
    described_class.run(['nonexistant_command'])
    expect($stderr.string)
      .to match(/Unknown command 'nonexistant_command'\n/)
  end

  it 'has a get_service command that formats responses as JSON' do
    configurator = double
    expect(Confidant::Configurator).to receive(:new).and_return(configurator)

    client = double
    expect(client).to receive(:get_service).and_return(hello: 'world')
    expect(client).to receive(:suppress_errors).and_return(true)
    expect(Confidant::Client).to receive(:new).and_return(client)

    described_class.run(['get_service'])
    expect($stdout.string)
      .to match("{\n  \"hello\": \"world\"\n}\n")
  end

  it 'has a show_config command that can show config' do
    configurator = double
    expect(configurator).to receive(:config).and_return(hello: 'world')
    expect(Confidant::Configurator).to receive(:new).and_return(configurator)

    described_class.run(['show_config'])
    expect($stdout.string)
      .to match(/---\n:hello: world/)
  end

  it 'can clean a GLI options hash' do
    gli_opts = {
      'config-files' => '~/.confidant,/etc/confidant/config',
      :"config-files" => '~/.confidant,/etc/confidant/config',
      'log-level' => 'info',
      :"log-level" => 'info',
      'u' => nil,
      :u => nil,
      'url' => nil,
      :url => nil,
      'k' => 'an-auth-key',
      :k => 'an-auth-key',
      'auth-key' => 'an-auth-key',
      :"auth-key" => 'an-auth-key',
      'version' => false,
      :version => false,
      'help' => false,
      :help => false
    }
    expect(described_class.clean_opts(gli_opts))
      .to eq(
        config_files: ['~/.confidant', '/etc/confidant/config'],
        log_level: 'info',
        auth_key: 'an-auth-key'
      )
  end
end
