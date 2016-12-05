$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter,
   Coveralls::SimpleCov::Formatter]
)

SimpleCov.start do
  add_filter '/spec/'
end

require 'pp'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end

require 'confidant'
require 'confidant/cli'
