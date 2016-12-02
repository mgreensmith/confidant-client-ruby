require 'logging'

include Logging.globally(:log)

require 'confidant/version'

# This is a set of client libs for Confidant
module Confidant
  Logging.logger.root.appenders = Logging.appenders.stderr
  Logging.logger.root.level = :info

  # An invalid configuration was provided
  class ConfigurationError < StandardError
  end

  require 'confidant/configurator'
  require 'confidant/client'

  module_function

  # Wrap Configurator.configure for convenience.
  def configure(config = {})
    Configurator.configure(config)
  end

  def log_exception(klass, ex)
    klass.log.error("#{ex.class} : #{ex.message}")
    ex.backtrace.each do |frame|
      klass.log.debug("\t#{frame}")
    end
  end
end
