require 'loggability' unless defined?( Loggability )
require 'loggability/formatter' unless defined?( Loggability::Formatter )

class Loggability::Formatter::Timeless < Loggability::Formatter

  # The format to output unless debugging is turned on
  FORMAT = "%5$5s {%6$s} -- %7$s\n"

  def initialize( format=FORMAT )
    super
  end

end