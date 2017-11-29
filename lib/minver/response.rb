class Minver::Response
  DEFAULT_HEADERS = {
    "Content-Type" => "text/html; charset=utf-8",
    "Server" => "Minver/1.0",
    "Connection" => "close"
  }

  def initialize status, headers, body
    headers["Content-Length"] = body.length
    @status = status
    @headers = DEFAULT_HEADERS.merge(
      "Date" => Time.now.strftime("%a, %d %b %Y %H:%M:%S %Z")
    ).merge(headers)
    @body = body
  end

  def body
    @body
  end

  def data
    [status_line, *header_lines, '', body].join("\n")
  end

  def status_line
    ["HTTP/#{Minver::Base::HTTP_VERSION}", @status, Minver::Base::HTTP_CODES[@status]].join(' ')
  end

  def header_lines
    @headers.map do |k, v|
      [k, v].join(": ")
    end
  end

  def self.from var
    case var
    when String
      new(200, {}, var)
    when Array
      new(*var)
    end
  end
end
