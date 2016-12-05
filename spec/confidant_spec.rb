require 'spec_helper'

describe Confidant do
  before(:each) do
    if Confidant.instance_variable_defined? :@configurator
      Confidant.remove_instance_variable :@configurator
    end
  end

  it 'has a version number' do
    expect(Confidant::VERSION).not_to be nil
  end

  context 'module workflow' do
    before(:each) do
      stub_const('Confidant::Configurator::MANDATORY_CONFIG_KEYS', global: [])
    end

    it 'creates a module instance of Configurator' do
      expect { Confidant.configure }.to_not raise_error
    end

    context '#get_service' do
      it 'raises if not configured' do
        expect { Confidant.get_service }
          .to raise_error(Confidant::ConfigurationError,
                          /Not configured, run Confidant.configure/)
      end

      it 'returns a Client response' do
        allow_any_instance_of(Confidant::Client)
          .to receive(:get_service).and_return(it: 'worked')

        Confidant.configure
        expect(Confidant.get_service).to eq(it: 'worked')
      end
    end
  end
end

describe Confidant::ConfigurationError do
  it 'subclasses StandardError' do
    expect(Confidant::ConfigurationError).to be_kind_of(StandardError.class)
  end
end
