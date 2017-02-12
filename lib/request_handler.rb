class RequestHandler

  attr_reader :original_request, :request_hash

  def initialize
    @original_request = []
  end

  def receive_request socket
    while line = socket.gets and !line.chomp.empty?
      puts "Reading request..."
      original_request << line.chomp.split(":")
    end
    original_request
  end

  def build_request_hash
    request_hash = {}
    original_request.each do |line|
      if line.length == 1
        request_hash.merge!(first_line_hash(line))
      elsif line[0] == "Host"
        request_hash[:host] = line[1]
        request_hash[:port] = line[2]
      end
      request_hash[:accept] = line[1] if line[0] == "Accept"
      request_hash[:origin] = request_hash[:host] # where does origin come from? Nested in the request?
    end
    request_hash
  end

  def first_line_hash line
    first_line_hash = {}
    line = line[0].split(" ")
    first_line_hash[:verb] = line[0]
    first_line_hash.merge!(path_hash(line[1]))
    first_line_hash[:protocol] = line[2]
    first_line_hash
  end

  def path_hash path
    path_hash = {}
    path = path.split("?")
    path_hash[:path] = path.shift
    path_hash[:params] = {}
    path.length.times do |i|
      key_val_tuple = path[i].split("=")
      path_hash[:params][key_val_tuple[0].to_sym] = key_val_tuple[1]
    end
    path_hash
  end 
end