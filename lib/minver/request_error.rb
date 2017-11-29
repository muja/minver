module Minver
  class RequestError < StandardError
    attr_reader :code, :message, :headers, :cause

    def initialize(message, code, headers: {}, cause: nil)
      super(message)
      @code = code
      @message = message
      @headers = headers
      @cause = cause
    end
  end
end
