require 'logging'
require 'confidant/version'

include Logging.globally(:log)

# This is a set of client libs for Confidant
module Confidant
  Logging.logger.root.appenders = Logging.appenders.stderr
  Logging.logger.root.level = :info
end
