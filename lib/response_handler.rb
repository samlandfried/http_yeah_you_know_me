require './lib/game'

class ResponseHandler

  attr_reader :request, :output, :headers

  def initialize request
    @request = request
  end

  def serve_path server
    case request[:path]
    when "/"
      write_request_info
    when "/game"
      handle_game(server)
    when "/start_game"
      server.game= Game.new
    when "/hello"
      "Hello, World! (#{server.counts[:hello]})"
    when "/datetime"
      "#{Time.now.strftime('%I:%M%p on %A, %B %d, %Y')}"
    when "/word_search"
      word = request[:params][:word]
      is_it_in_dictionary?(word)
    when "/shutdown"
      "Total Requests: #{server.counts[:total]}"
    end
  end

  def write_request_info
    to_print = "<pre>\n"
    request.each do |key, value|
      to_print += key.to_s.capitalize + ": " + value.to_s + "\n"
    end
    to_print + "</pre>"
  end

  def write_response response, status = 200, extra_headers = []
    @output = "<html><head></head><body>#{response}</body></html>"
    @headers = ["http/1.1 #{status}",
                "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                "server: ruby",
                "content-type: text/html; charset=iso-8859-1",
                "content-length: #{output.length}\r\n\r\n"]
    extra_headers.each {|header| headers.insert(1, header)}
    @headers = headers.join("\r\n")
  end

  def is_it_in_dictionary? word
    dic = File.open("/usr/share/dict/words", "r").read
    response = word + " is a word!"
    response.insert(word.length + 3, " NOT") unless dic.include?(word)
    response
  end

  def handle_game(server)
    if request[:verb] == "POST"
      server.game.guess(request[:params][:guess])
      write_response("Redirecting", 302, ["location: http://127.0.0.1:9292/game"])
      "redirect"
    elsif request[:verb] == "GET"
      server.game.get_info
    else
      "I only take POST and GET"
    end
  end
end
