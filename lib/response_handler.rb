class ResponseHandler

  attr_reader :request, :output, :headers

  def initialize request
    @request = request
  end

  def serve_path counts
    case request[:path]
    when "/"
      write_request_info
    when "/hello"
      "Hello, World! (#{counts[:hello]})"
    when "/datetime"
      "#{Time.now.strftime('%I:%M%p on %A, %B %d, %Y')}"
    when "/word_search"

    when "/shutdown"
      "Total Requests: #{counts[:total]}"
    end
  end

  def write_request_info
    to_print = "<pre>\n"
    request.each do |key, value|
      to_print += key.to_s.capitalize + ": " + value + "\n"
    end
    to_print + "</pre>"
  end

  def write_response response
    @output = "<html><head></head><body>#{response}</body></html>"
    @headers = ["http/1.1 200 ok",
                "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                "server: ruby",
                "content-type: text/html; charset=iso-8859-1",
                "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

end
