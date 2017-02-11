class RequestHandler

  def self.receive_request socket
    request_lines = []
    while line = socket.gets and !line.chomp.empty?
      puts "Reading request..."
      request_lines << line.chomp.split(":")
    end
    request_lines
  end

  def self.build_request_hash request
    request_hash = {}
    request.each do |line|
      if line.length == 1
        line = line[0].split(" ")
        request_hash[:verb] = line[0]
        request_hash[:path] = line[1]
        request_hash[:protocol] = line[2]
      elsif line[0] == "Host"
        request_hash[:host] = line[1]
        request_hash[:port] = line[2]
      end
      request_hash[:accept] = line[1] if line[0] == "Accept"
      request_hash[:origin] = request_hash[:host] # where does origin come from? Nested in the request?
    end
    request_hash
  end

end
