require 'socket'
require 'minver/request'
require 'minver/response'
require 'minver/request_error'

module Minver
  class Base

    HTTP_VERSION = "1.1"
    HTTP_METHODS = %w(GET POST PATCH PUT DELETE HEAD)
    HTTP_CODES = {
      100 => "Continue",
      101 => "Switching Protocols",
      103 => "Checkpoint",
      200 => "OK",
      201 => "Created",
      202 => "Accepted",
      203 => "Non-Authoritative Information",
      204 => "No Content",
      205 => "Reset Content",
      206 => "Partial Content",
      300 => "Multiple Choices",
      301 => "Moved Permanently",
      302 => "Found",
      303 => "See Other",
      304 => "Not Modified",
      306 => "Switch Proxy",
      307 => "Temporary Redirect",
      308 => "Resume Incomplete",
      400 => "Bad Request",
      401 => "Unauthorized",
      402 => "Payment Required",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      406 => "Not Acceptable",
      407 => "Proxy Authentication Required",
      408 => "Request Timeout",
      409 => "Conflict",
      410 => "Gone",
      411 => "Length Required",
      412 => "Precondition Failed",
      413 => "Request Entity Too Large",
      414 => "Request-URI Too Long",
      415 => "Unsupported Media Type",
      416 => "Requested Range Not Satisfiable",
      417 => "Expectation Failed",
      422 => "Unprocessable Entity",
      423 => "Locked",
      424 => "Failed Dependency",
      500 => "Internal Server Error",
      501 => "Not Implemented",
      502 => "Bad Gateway",
      503 => "Service Unavailable",
      504 => "Gateway Timeout",
      505 => "HTTP Version Not Supported",
      511 => "Network Authentication Required"
    }

    def initialize(**options, &block)
      @bind = options.fetch(:bind, '::')
      @port = options.fetch(:port, 18167)
      @clients = []
      instance_eval(&block) if block_given?
    end

    def server
      @server ||= TCPServer.new @bind, @port
    end

    def on(method, uri, &block)
      triggers[method][uri] = block
    end

    HTTP_METHODS.each do |method|
      define_method method.downcase do |uri, &block|
        on(method, uri, &block)
      end
    end

    def run(**options)
      $stderr.puts "Listening on #{@bind}:#{@port}." if $DEBUG
      loop do
        result = IO.select([server, *@clients], *([nil, nil, 0] if options[:nonblock]))
        return unless result
        result.first.each do |client|
          # it's possible that "client" here is the server so we extract the client from it.
          @clients << (client = client.accept) if client.respond_to?(:accept)
          if client.eof?
            @clients.delete(client).close
            next
          end
          begin
            request = Request.new(client)
            $stderr.puts request.data.lines.map{|l| "< #{l}"} if $DEBUG
            block = triggers[request.http_method][request.path]
            response = if block
              begin
                Response.from(instance_exec(request, &block))
              rescue => e
                raise RequestError.new(
                  "An error occurred. Check the logs or ask the administrator.",
                  500,
                  cause: e
                )
              end
            else
              raise RequestError.new("The resource you were looking for does not exist.", 404)
            end
            if @should_pass
              @should_pass = false
              return @return_value
            end
          rescue RequestError => e
            response = Response.from([e.code, e.headers, e.message])
            raise e.cause || e if (500..599).include? e.code
          ensure
            $stderr.puts response.data.lines.map{|l| "> #{l}"} if $DEBUG
            client.write(response.data)
          end
        end
      end
    end

    def stop return_value=nil
      pass return_value
      server.close
    end

    def pass return_value
      @should_pass = true
      @return_value = return_value
    end

  protected
    def triggers
      @triggers ||= HTTP_METHODS.inject({}){ |h, m| h.merge(m => {}) }
    end
  end
end
