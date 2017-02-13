require 'minitest/autorun'
require 'minitest/emoji'
require 'faraday'
require 'pry'

require './lib/server'

class ServerTest < Minitest::Spec



  describe 'When it starts' do

    attr_reader :response, :server

    before do
      @server = Server.new(123)
      @response = Faraday.get("http://127.0.0.1:9292")
    end

    it "should listen to and respond on port 9292" do
      ->{Faraday.get("http://127.0.0.1:929")}.must_raise Faraday::ConnectionFailed
      response.status.must_equal 200
    end

    it "should be ready to count requests" do
      server.counts[:total].must_equal 0
      server.counts[:hello].must_equal 0
    end

  end


  describe "When a request is made to /" do

    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

    it "should serve the request info" do
      # binding.pry
      response.body.must_include("Verb: GET\nPath: /\nParams: {}\nProtocol: HTTP/1.1\nUser-agent: Faraday v0.11.0\nAccept-encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3\nAccept: */*\nConnection: close\nHost: 127.0.0.1\nPort: 9292")
    end
  end

  describe "When a request is made to /hello" do

    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292/hello")
    end

    it "should say hello" do
      response.body.must_include "Hello, World"
    end

    it "should count requests" do
      response.body.wont_equal Faraday.get("http://127.0.0.1:9292").body
    end
  end

  describe "When a request is made to /datetime" do
    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

  end

  describe "When a request is made to /start_game" do
    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

  end


  describe "When a request is made to /game" do
    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

  end

  describe "When a request is made to /force_error" do
    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

  end

  describe "When a request is made to root" do
    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

  end

  describe "When a request is made to root" do
    attr_reader :response

    before do
      @response = Faraday.get("http://127.0.0.1:9292")
    end

  end

end
