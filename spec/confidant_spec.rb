require 'spec_helper'

describe Confidant do
  it 'has a version number' do
    expect(Confidant::VERSION).not_to be nil
  end

  it 'has a configure method' do
    expect(Confidant).to respond_to(:configure).with(0..1).arguments
  end

  it 'has a log_exception method' do
    expect(Confidant).to respond_to(:log_exception).with(2).arguments
  end
end

describe Confidant::ConfigurationError do
  it 'subclasses StandardError' do
    expect(Confidant::ConfigurationError).to be_kind_of(StandardError.class)
  end
end
