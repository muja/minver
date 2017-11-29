require 'stringio'

module Minver
  class Parser
    def initialize(stream_or_string)
      @stream = if stream_or_string.is_a? String
        StringIO.new(stream_or_string)
      else
        stream_or_string
      end
    end

    def http_method
      @http_method ||= request_match[1]
    end

    def request_url
      @request_url ||= request_match[2]
    end

    def request_http_version
      @request_http_version ||= request_match[3]
    end

    def headers
      @headers ||= header_lines.inject({}) do |h, line|
        h.merge(Hash[[line.rstrip.split(': ', 2)]])
      end
    end

    def [](key)
      headers[key]
    end

    def data
      @data ||= [*head, body].join
    end

    def body
      @body ||= @stream.read(headers["Content-Length"].to_i)
    end

    def path
      @path ||= request_url.split('?')[0]
    end

    def query_string
      @query_string ||= request_url.split('?')[1] || ''
    end

  protected
    def request_match
      @request_match ||= request_line.match(/(\S+)\s+(\S+)(?:\s+HTTP\/(\S+)?)/)
    end

    def request_line
      @request_line ||= head.lines.first
    end

    def header_lines
      @header_lines ||= head.lines[1...-1]
    end

    def head
      @head ||= "".tap do |h|
        begin
          h << line = @stream.readline # TODO: non-blocking
        end until ["\r\n", "\n"].include? line
      end
    end
  end
end
