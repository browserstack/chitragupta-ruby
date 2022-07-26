require "logger"

module Chitragupta
  class Logger < Logger
    def initialize(*args)
      super(*args)
      @formatter = Chitragupta::JsonLogFormatter.new
      @progname = @logdev.filename
    end
  end
end
