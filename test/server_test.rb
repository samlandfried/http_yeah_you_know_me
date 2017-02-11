require 'minitest/autorun'
require 'minitest/emoji'
require 'faraday'
require 'pry'

# require './lib/server'


class ServerTest < Minitest::Spec
  describe 'Iteration 0' do

    before do
      # puts response
    end

    it "should listen on port 9292" do
      response = Faraday.get("http://127.0.0.1:2000")
      # response = conn.get
      puts response
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