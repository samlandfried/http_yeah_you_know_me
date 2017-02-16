module ServerMethods

  def kill
    response_handler.write_response("Total Requests: #{counts[:total]}")
    shutdown = true
  end

  def force_error
    begin
      raise(StandardError, "Just kidding!", caller)
    rescue StandardError => err_deets
      response_handler.write_response(err_deets.backtrace.join("<br>"), 500)
    end
  end

  def redirect path, msg
    response_handler.write_response(msg, 302, ["location: #{path}"])
  end

  def is_it_in_dictionary? word
    return word + " is a word!" if dictionary.include?(word + "\n")
    return word + " is NOT a word!"
  end

  def hear_request
    @request_handler = RequestHandler.new
    request_handler.receive_request(socket)
    puts "Got this request:\n#{request_handler.original_request.join("\n")}"
  end

  def build_request
    request_handler.build_request_hash
    request_body_length = request_handler.request_hash[:"Content-Length"].to_i
    request_handler.read_body(socket, request_body_length)
    request_handler.get_params(request_handler.request_hash[:body])
    request_handler.request_hash
  end

  def build_response request
    @response_handler = ResponseHandler.new(self)
    response_handler.serve_path(request)
  end

  def respond
    puts "Writing response..."
    socket.puts response_handler.headers
    socket.puts response_handler.output
    puts "Wrote this response:\n#{response_handler.output}"
    puts "With these headers:\n#{response_handler.headers}"
  end

  def start_game verb
    return response_handler.write_response("Try with a POST, please.") unless verb == "POST"
    return response_handler.write_response("Game's already started.", 403) if game.instance_of?(Game)
    @game = Game.new
    redirect("http://127.0.0.1:9292/game", "Started!")
  end

  def say_hello_for_the_nth_time
    counts[:hello] += 1
    response_handler.write_response("Hello, World! (#{counts[:hello]})")
  end
end
