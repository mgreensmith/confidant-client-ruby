require 'loggability' unless defined?(Loggability)
require 'loggability/formatter' unless defined?(Loggability::Formatter)

module Loggability
  class Formatter
    # A formatter that excludes timestamps and PID.
    class Timeless < Loggability::Formatter
      # The format to output unless debugging is turned on
      FORMAT = "%5$5s {%6$s} -- %7$s\n".freeze

      def initialize(format = FORMAT)
        super
      end
    end
  end
end
