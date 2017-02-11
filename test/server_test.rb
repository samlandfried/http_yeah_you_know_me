require 'minitest/autorun'
require 'minitest/emoji'
require 'faraday'
require 'pry'

require './lib/server'


class ServerTest < Minitest::Spec
  describe 'Iteration 0' do

    attr_reader :server

    before do
      # puts response
      server = Server.new(2525).listen
    end

    it "should listen on port 9292" do
      ->{Faraday.get("http://127.0.0.1:2525")}.must_throw ConnectionFailed
    end

    it "should respond to HTTP requests" do

    end

    it "displays 'Hello, World!'" do
    end

    it "counts the number of server requests" do
    end

    after do
    end
  end
end