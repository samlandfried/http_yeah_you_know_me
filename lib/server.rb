require 'socket'
require 'pry'

class Server

  # attr's not working as I would expect... why?

  attr_accessor :server, :socket, :counter, :output, :headers

  def initialize port
    @server = TCPServer.new port
    @headers = ["headers"]
    @output = "output"
    @counter = 0
  end

  def listen
    loop do
      puts "Listening for request..."
      @socket = server.accept
      @counter += 1 # <------- I can't access counter as an attr_accessor
      request = receive_request
      puts "Got this request:\n#{request.join("\n")}"
      request = build_request_hash request

      response = serve_path request
      puts "Writing response..."
      write_response response
      socket.puts headers # <-- But I can access headers and output here via attr_accessor, but not in .write_response
      socket.puts output
      puts "Wrote this response:\n#{output}"
      puts "With these headers:\n#{headers}"
      socket.close
    end
  end

  def serve_path request
    case request[:path]
    when "/"
      write_request_info request
    when "/hello"
      "Hello"
    when "/datetime"
      "Date"
    when "/shutdown"
      "Shutdown"
    end
  end

  def receive_request
    request_lines = []
    while line = socket.gets and !line.chomp.empty?
      puts "Reading request..."
      request_lines << line.chomp.split(":")
    end
    request_lines
    # binding.pry
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
  
  def build_request_hash request_ary
    request_hash = {}
    request_ary.each do |line|
      # binding.pry
      if line.length == 1
        line = line[0].split(" ")
        request_hash[:verb] = line[0]
        request_hash[:path] = line[1]
        request_hash[:protocol] = line[2]
      elsif line[0] == "Host"
        request_hash[:host] = line[1]
        request_hash[:port] = line[2]
      end
      request_hash[:accept] = line[1] if line[0] == "Accept"
      request_hash[:origin] = request_hash[:host] # where does origin come from? Nested in the request?
    end
    # binding.pry
    request_hash
  end

  def write_response data
    # puts "======DATA======\n#{data}\n=============="

    response = data
    # %{
    #   <pre>
    #   Verb: #{data[:verb]}
    #   Path: #{data[:path]}
    #   Protocol: #{data[:protocol]}
    #   Host: #{data[:host]}
    #   Port: #{data[:port]}
    #   Origin: #{data[:origin]}
    #   Accept: #{data[:accept]}
    #   </pre>
    # }
    @output = "<html><head></head><body>#{response}</body></html>"
    @headers = ["http/1.1 200 ok",
                "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                "server: ruby",
                "content-type: text/html; charset=iso-8859-1",
                "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end
end

Server.new(9292).listen
