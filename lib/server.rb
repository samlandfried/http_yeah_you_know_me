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
    @game = "Fidgey widgets"
  end

  def listen
    loop do
      puts "Listening for request..."
      @socket = server.accept

      request_handler = RequestHandler.new
      request_handler.receive_request(socket)
      puts "Got this request:\n#{request_handler.original_request.join("\n")}"
      request = request_handler.build_request_hash

      if request[:verb] == "POST"
        request.merge!(request_handler.read_body(socket, request[:"Content-Length"].to_i))
        request.merge!(request_handler.params_hash(request_handler.request_hash[:body]))
      end

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
