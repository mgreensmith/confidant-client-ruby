require 'logging'
require 'confidant/version'

include Logging.globally( :log )

module Confidant
  Logging.logger.root.appenders = Logging.appenders.stdout
  Logging.logger.root.level = :info
end
