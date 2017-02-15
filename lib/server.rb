require 'socket'
require 'pry'

require './lib/request_handler'
require './lib/response_handler'
require './lib/game'

class Server

  attr_reader :server, :socket, :counts, :dictionary
  attr_accessor :game, :shutdown

  def initialize port
    @server = port
    @shutdown = false
    @counts = {:hello => 0, :total => 0}
    @game = nil
    @dictionary = File.open("/usr/share/dict/words", "r").read
  end

  def listen
    @server = TCPServer.new(server)
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

      response_handler = ResponseHandler.new(self)
      response_handler.serve_path(request)

      puts "Writing response..."
      # every path must ultimately write a response

      socket.puts response_handler.headers
      socket.puts response_handler.output
      puts "Wrote this response:\n#{response_handler.output}"
      puts "With these headers:\n#{response_handler.headers}"

      puts "\n\nAnd for debugging purposes...\n\n#{response_handler.write_info(request)}"

      socket.close
      break if shutdown
    end
  end

  def start_game
    @game = Game.new
  end
end
