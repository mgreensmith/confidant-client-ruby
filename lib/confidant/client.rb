module Confidant
  class Client

    attr_reader :key

    def initialize(key)
      @key = key
    end
  end
end