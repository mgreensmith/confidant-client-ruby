require 'logging'

include Logging.globally(:log)

require 'confidant/version'

# This is a set of client libs for Confidant
module Confidant
  Logging.logger.root.appenders = Logging.appenders.stderr
  Logging.logger.root.level = :info

  require 'confidant/configurator'
  require 'confidant/client'

  module_function

  def configure(config = {})
    Configurator.configure(config)
  end
end
