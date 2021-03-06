require 'socket'

require './lib/request_handler'
require './lib/response_handler'
require './lib/game'
require './lib/server_methods'
require './lib/complete_me'

class Server

  include ServerMethods

  attr_reader :server,
    :socket,
    :counts,
    :dictionary,
    :request_handler,
    :response_handler

  attr_accessor :game,
    :shutdown

  def initialize port
    @server = port
    @shutdown = false
    @counts = {:hello => 0, :total => 0}
    @game = nil
    @dictionary = CompleteMe.new
    dictionary.populate(File.open("/usr/share/dict/words", "r").read)
  end

  def spinup
    @server = TCPServer.new(server)
    until shutdown
      puts "Listening for request..."
      @socket = server.accept

      hear_request
      request = build_request

      build_response(request)
      respond

      socket.close
    end
  end
end
