require 'socket'

class Server

  attr_reader :server

  attr_accessor :counter

  def initialize port
    @server = TCPServer.new port
    @counter = 0
  end

  def listen
    loop do
      # Thread.start(server.accept) do |client|
      client = server.accept
      increment_counter
      client.puts "Hello!"
      client.puts "Time is #{Time.now}"
      client.puts "#{counter}"
      client.close
      # end
    end
  end

  def increment_counter
    counter += 1
  end


end

Server.new(9292).listen
