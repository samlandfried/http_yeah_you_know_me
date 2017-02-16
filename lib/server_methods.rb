module ServerMethods

  def kill
    self.response_handler.write_response("Total Requests: #{self.counts[:total]}")
    self.shutdown = true
  end

  def force_error
    begin
      raise(StandardError, "Just kidding!", caller)
    rescue StandardError => err_deets
      self.response_handler.write_response(err_deets.backtrace.join("<br>"), 500)
    end
  end

  def redirect path, msg
    self.response_handler.write_response(msg, 302, ["location: #{path}"])
  end

  def start_game verb
    return self.response_handler.write_response("Try with a POST, please.") unless verb == "POST"
    return self.response_handler.write_response("Game's already started.", 403) if self.game.instance_of?(Game)
    self.game = Game.new
    redirect("http://127.0.0.1:9292/game", "Started!")
  end
end
