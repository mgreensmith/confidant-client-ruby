require 'loggability'
require 'loggability/formatter/timeless'

require 'confidant/version'

# This is a set of client libs for Confidant
module Confidant
  extend Loggability
  log_as :confidant

  # An invalid configuration was provided
  class ConfigurationError < StandardError
  end

  require 'confidant/configurator'
  require 'confidant/client'

  module_function

  ### Wrap common workflow into module methods for end-user simplicity.

  def configure(config = {})
    @configurator = Configurator.new(config)
  end

  def get_service(service = nil)
    unless @configurator
      raise ConfigurationError, 'Not configured, run Confidant.configure'
    end
    Client.new(@configurator).get_service(service)
  end

  def log_exception(klass, ex)
    klass.log.error("#{ex.class} : #{ex.message}")
    ex.backtrace.each do |frame|
      klass.log.debug("\t#{frame}")
    end
  end
end
