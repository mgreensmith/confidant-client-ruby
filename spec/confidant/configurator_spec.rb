require 'spec_helper'
require 'fileutils'

describe Confidant::Configurator do
  include FakeFS::SpecHelpers

  before do
    @min_config = {
      'from' => 'hypatia',
      'to' => 'aedesia',
      'auth_key' => 'astrolabe',
      'url' => 'athens'
    }
  end

  def write_file(path, name, config)
    FileUtils.mkdir_p(path)
    fpath = File.join(File.expand_path(path), name)
    File.open(File.expand_path(fpath), 'w') do |f|
      f.write config.to_yaml
    end
  end

  it 'looks for configuration files from params' do
    write_file('/some', 'config', 'default' => @min_config)
    expect { described_class.new(config_files: ['/some/config']) }
      .to_not raise_error
  end

  it 'uses config from the first discovered file' do
    write_file('/some', 'first', 'default' => @min_config)

    second_config = @min_config.dup
    second_config[:auth_key] = 'sextant'
    write_file('/some', 'second', 'default' => second_config)

    configurator = described_class.new(
      config_files: %w(/some/first /some/second)
    )
    expect(configurator.config).to_not include(auth_key: 'sextant')
  end

  it 'expects to find the configured profile in the first discovered file' do
    write_file('/etc/confidant', 'config', 'other_profile' => @min_config)
    expect { described_class.new }
      .to raise_error(Confidant::ConfigurationError,
                      /Profile 'default' not found/)
    write_file('/etc/confidant', 'config', 'default' => @min_config)
    expect { described_class.new }.to_not raise_error
  end

  it 'strips meta-config options' do
    write_file('/etc/confidant', 'config', 'default' => @min_config)
    configurator = described_class.new
    expect(configurator.config).to_not have_key(:config_files)
    expect(configurator.config).to_not have_key(:log_level)
    expect(configurator.config).to_not have_key(:profiles)
  end

  it 'includes defaults for unspecified keys' do
    write_file('/etc/confidant', 'config', 'default' => @min_config)
    expect(described_class.new.config).to include(token_lifetime: 10,
                                                  token_version: 2,
                                                  user_type: 'service',
                                                  region: 'us-east-1')
  end

  it 'handles config keys found in :auth_context (for compatibility)' do
    auth_context_config = {
      'auth_context' => {
        'from' => 'hypatia',
        'to' => 'aedesia'
      },
      'from' => 'plato', # Should be overriden
      'to' => 'aristotle', # Should be overriden
      'auth_key' => 'astrolabe',
      'url' => 'athens'
    }
    write_file('/etc/confidant', 'config', 'default' => auth_context_config)
    expect(described_class.new.config).to include(from: 'hypatia',
                                                  to: 'aedesia')
  end

  it 'knows minimum required global config keys' do
    insufficient_config = {
      'from' => 'hypatia',
      'to' => 'aedesia',
      'auth_key' => 'astrolabe'
    }
    write_file('/etc/confidant', 'config', 'default' => insufficient_config)
    expect { described_class.new }
      .to raise_error(Confidant::ConfigurationError,
                      /Missing required config keys: url/)
  end

  it 'validates command-specific keys if command was specified' do
    stub_const('Confidant::Configurator::MANDATORY_CONFIG_KEYS',
               global: [], wibble: [:wobble])
    expect do
      described_class.new(
        { wibble: { not_wobble: 'foo' } },
        'wibble'
      )
    end.to raise_error(Confidant::ConfigurationError,
                       /Missing required config keys: wibble\[wobble\]/)
  end

  it 'validates any found command-specific keys opportunistically' do
    stub_const('Confidant::Configurator::MANDATORY_CONFIG_KEYS',
               global: [], wibble: [:wobble])
    expect { described_class.new(wibble: { not_wobble: 'foo' }) }
      .to raise_error(Confidant::ConfigurationError,
                      /Missing required config keys: wibble\[wobble\]/)
  end
end
