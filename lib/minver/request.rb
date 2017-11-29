require 'minver/parser'
require 'uri'
require 'yaml'

module Minver
  class Request
    attr_reader :params

    def initialize(client)
      @client = client
      @params = Hash[URI.decode_www_form(parser.query_string)].tap do |params|
        begin
          puts headers.to_yaml if $DEBUG
          params.merge! case type = headers["Content-Type"]
          when 'application/json'
            require 'json'
            JSON.parse(body)
          when 'application/x-www-form-urlencoded'
            Hash[URI.decode_www_form(body)]
          else
            {}
          end
        rescue => e
          raise RequestError.new(
            "The given content-type is not recognized or the content data is malformed.",
            400,
            cause: e
          )
        end
      end
    end

    [:http_method, :headers, :[], :path, :data, :body].each do |method|
      define_method method do
        parser.public_send(method)
      end
    end

    def parser
      @parser ||= Minver::Parser.new(@client)
    end
  end
end
