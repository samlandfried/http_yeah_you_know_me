require './lib/game'

class ResponseHandler

  attr_reader :request, :output, :headers

  def initialize request
    @request = request
  end

  def serve_path server
    case request[:path]
    when "/" then write_response(write_request_info)
    when "/game" then handle_game(server)
    when "/start_game" then if request[:verb] == "POST"
      unless server.game.instance_of?(Game)
        server.game= Game.new
        write_response("Game started. Redirecting...", 302, ["location: http://127.0.0.1:9292/game"])
      else
        write_response("Game's already started.", 403)
      end
    else
      write_response("Try with a POST, please.")
    end
    when "/hello" then write_response("Hello, World! (#{server.counts[:hello] += 1})")
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

def handle_game(server)
  if request[:verb] == "POST"
    server.game.guess(request[:params][:guess])
    write_response("Redirecting", 302, ["location: http://127.0.0.1:9292/game"])
    "redirect"
  elsif request[:verb] == "GET"
    write_response(server.game.get_info)
  else
    write_response("I only take POST and GET")
  end
end
end
