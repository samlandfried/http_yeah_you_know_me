require 'socket'
require 'pry'

require './lib/request_handler'
require './lib/response_handler'

class Server

  # attr's not working as I would expect... why?

  attr_accessor :server, :socket, :requests_counter, :hello_counter, :output, :headers, :keep_listening
  attr_reader :response_hander, :request_handler

  def initialize port
    @server = TCPServer.new port
    @requests_counter = 0
  end

  def listen
    loop do
      puts "Listening for request..."
      @socket = server.accept
      @requests_counter += 1 # <------- I can't access requests_counter as an attr_accessor

      request = RequestHandler.receive_request socket
      puts "Got this request:\n#{request.join("\n")}"
      request = RequestHandler.build_request_hash(request) 

      response_handler = ResponseHandler.new(request)
      response = response_handler.serve_path
      puts "Writing response..."
      write_response response
      socket.puts response_handler.headers # <-- But I can access headers and output here via attr_accessor, but not in .write_response
      socket.puts response_handler.output
      puts "Wrote this response:\n#{response_handler.output}"
      puts "With these headers:\n#{response_handler.headers}"
      socket.close
      break if request[:path] == "/shutdown"
    end
  end
end

Server.new(9292).listen
