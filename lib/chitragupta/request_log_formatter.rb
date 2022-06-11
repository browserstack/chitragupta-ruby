require 'chitragupta/constants'

module Chitragupta
  module RequestLogFormatter
    FORMAT = ->(message) {
        message[:log] = {}
        return message
      }
  end
end
