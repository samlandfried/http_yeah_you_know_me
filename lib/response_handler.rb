class ResponseHandler

  attr_reader :server, :output, :headers

  def initialize server
    @server = server
  end

  def serve_path request
    verb = request[:verb]; params = request[:params]; game = server.game
    case request[:path]
    when "/" then write_response(write_info(request))
    when "/game" then game.handle_game(params[:guess], verb, server) if game
    when "/start_game" then server.start_game(verb)
    when "/hello" then server.say_hello_for_the_nth_time
    when "/datetime" then write_response(Time.now.strftime('%I:%M%p on %A, %B %d, %Y'))
    when "/word_search" then write_response(server.is_it_in_dictionary?(params[:word]))
    when "/shutdown" then server.kill
    when "/force_error" then server.force_error
    else write_response("Nope.", 404)
    end
  end

  def write_info request
    to_print = "<pre>\n"
    request.each do |key, value|
      to_print += key.to_s.capitalize + ": " + value.to_s + "\n"
    end
    to_print + "</pre>"
  end

  def write_response response, status = 200, extra_headers = []
    @output = "<html><head></head><body>#{response}</body></html>"
    @headers = write_headers(status, extra_headers)
  end

  def write_headers status, extra_headers
    headers = populate_headers(status)
    extra_headers.each {|header| headers << header}
    headers << "\r\n"; headers.join("\r\n")
  end

  def populate_headers status
    ["http/1.1 #{status}",
     "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
     "server: ruby",
     "content-type: text/html; charset=iso-8859-1",
     "content-length: #{output.length}"]
  end
end
