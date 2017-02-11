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
      puts "Got this request:\n#{request}"
      puts "Writing response..."
      write_response
      socket.puts headers # <-- But I can access headers and output here via attr_accessor, but not in .write_response
      socket.puts output
      puts "Wrote this response:\n#{output}"
      puts "With these headers:\n#{headers}"
      socket.close
    end
  end

  def receive_request
    request_lines = []
    while line = socket.gets and !line.chomp.empty?
      puts "Reading request..."
      request_lines << line.chomp
    end
    request_lines.join("\n")
  end

  def write_response # attr_accessor
    response = "<pre>Hello, World! (#{counter})</pre>" # <---------- I can access counter via attr_accessor
    @output = "<html><head></head><body>#{response}</body></html>" # But not headers and output
    @headers = ["http/1.1 200 ok",
                "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                "server: ruby",
                "content-type: text/html; charset=iso-8859-1",
                "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end
end

Server.new(9292).listen
