require './lib/game'

class ResponseHandler

  attr_reader :request, :output, :headers

  def initialize request
    @request = request
  end

  def serve_path server
    case request[:path]
    when "/" then write_response(write_request_info)
    when "/game" then handle_game(server.game)
    when "/start_game" then server.start_game if ready_to_start?(server.game, request[:verb])
    when "/hello" then say_hello_for_the_nth_time(server.counts[:hello])
    when "/datetime" then write_response("#{Time.now.strftime('%I:%M%p on %A, %B %d, %Y')}")
    when "/word_search" then word = request[:params][:word]
      write_response(is_it_in_dictionary?(word))
    when "/shutdown" then write_response("Total Requests: #{server.counts[:total]}")
    when "/force_error" then begin
      raise(StandardError, "Nice one!", caller)
      rescue StandardError => bang
        write_response(bang.backtrace.join("<br>"), 500)
      end
    else
      write_response("Nope.", 404)
    end
  end

  def say_hello_for_the_nth_time n
    n += 1
    write_response("Hello, World! (#{n})")
  end

  def ready_to_start? game, verb
    # binding.pry
    return write_response("Try with a POST, please.") unless verb == "POST"
    return write_response("Game started. Redirecting...", 302, ["location: http://127.0.0.1:9292/game"]) unless game.instance_of?(Game)
    return write_response("Game's already started.", 403)
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

  #THIS WILL SAY ANY 'WORD' THAT IS PART OF ANOTHER WORD IS A WORD. LIKE "CARPEN"
  def is_it_in_dictionary? word
    dic = File.open("/usr/share/dict/words", "r").read
    response = word + " is a word!"
    response.insert(word.length + 3, " NOT") unless dic.include?(word)
    response
  end

  def handle_game(game)
    # binding.pry
    return write_response("Try starting a game first.") unless game.instance_of?(Game)
    if request[:verb] == "POST"
      game.guess(request[:params][:guess])
      write_response("Redirecting", 302, ["location: http://127.0.0.1:9292/game"])
      "redirect"
    elsif request[:verb] == "GET"
      write_response(game.get_info)
    else
      write_response("I only take POST and GET")
    end
  end
end
