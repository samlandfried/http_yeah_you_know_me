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

    attr_reader :response, :time, :day, :date, :year

    # "#{Time.now.strftime('%I:%M%p on %A, %B %d, %Y')}"
    before do
      @response = Faraday.get("http://127.0.0.1:9292/datetime")
      @time = Time.now.strftime('%I:%M%p')
      @day = Time.now.strftime('%A')
      @date = Time.now.strftime('%B %d')
      @year = Time.now.strftime('%Y')
    end

    it "should include time" do
      response.body.must_include(time)
    end

    it "should include day" do
      response.body.must_include(day)
    end

    it "should include date" do
      response.body.must_include(date)
    end

    it "should include year" do
      response.body.must_include(year)
    end

  end

  describe "When a request is made to /start_game" do # How do I get these to pass when the order of them is important? I need to kill and restart server. Might need to use Threads

    it "should not allow GETs" do
      response = Faraday.get("http://127.0.0.1:9292/start_game")
      response.body.must_include("Try with a POST, please.")
    end

    it "should start a new game and redirect" do
      response = Faraday.post("http://127.0.0.1:9292/start_game")
      response.body.must_include("Game started. Redirecting...")
      response.status.must_equal 302
    end

    it "should only start one game" do
      response = Faraday.post("http://127.0.0.1:9292/start_game")
      response.body.must_include "Game's already started."
      response.status.must_equal 403
    end


  end


  describe "When a request is made to /game" do

    attr_reader :response

    before do
      Faraday.post("http://127.0.0.1:9292/start_game")
      @response = Faraday.post("http://127.0.0.1:9292/game", {:guess => 7})
    end

    it "should display info for GET" do
      response = Faraday.get("http://127.0.0.1:9292/game")
      response.body.must_include("The last guess was 7")
    end

    it "should count guesses" do
      response = Faraday.get("http://127.0.0.1:9292/game")
      Faraday.post("http://127.0.0.1:9292/game", {:guess => 7})
      response2 = Faraday.get("http://127.0.0.1:9292/game")
      response.body.wont_equal response2.body
    end

    it "should redirect with a POST" do
      response.status.must_equal 302
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
