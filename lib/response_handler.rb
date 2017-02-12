class ResponseHandler

  attr_reader :request, :requests_counter, :output, :headers

  def initialize request
    @request = request
    @hello_counter = 0
    @requests_counter = 0
  end

  def serve_path counts
    case request[:path]
    when "/"
      write_request_info(request)
    when "/hello"
      "Hello, World! (#{counts[:hello]})"
    when "/datetime"
      "#{Time.now.strftime('%I:%M%p on %A, %B %d, %Y')}"
    when "/shutdown"
      "Total Requests: #{counts[:total]}"
    end
  end

  def write_request_info request
    %{
      <pre>
      Verb: #{request[:verb]}
      Path: #{request[:path]}
      Protocol: #{request[:protocol]}
      Host: #{request[:host]}
      Port: #{request[:port]}
      Origin: #{request[:origin]}
      Accept: #{request[:accept]}
      </pre>
    }
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
