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

end
