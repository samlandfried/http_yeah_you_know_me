require 'socket'
require 'pry'

require './lib/request_handler'
require './lib/response_handler'

class Server

  attr_reader :server, :socket, :counts
  attr_accessor :game

  def initialize port
    @server = TCPServer.new port
    @counts = {:hello => 0, :total => 0}
  end

  def listen
    loop do
      puts "Listening for request..."
      @socket = server.accept

      request = RequestHandler.new
      request.receive_request(socket)
      puts "Got this request:\n#{request.original_request.join("\n")}"
      request = request.build_request_hash
      counts[:total] += 1
      counts[:hello] += 1 if request[:path] == "/hello"

      response_handler = ResponseHandler.new(request)
      response = response_handler.serve_path(self)

      puts "Writing response..."
      response_handler.write_response(response)

      socket.puts response_handler.headers
      socket.puts response_handler.output
      puts "Wrote this response:\n#{response_handler.output}"
      puts "With these headers:\n#{response_handler.headers}"

      puts "\nAnd for debugging purposes...\n#{response_handler.write_request_info}"
      
      socket.close
      break if request[:path] == "/shutdown"
    end
  end
end

Server.new(9292).listen
