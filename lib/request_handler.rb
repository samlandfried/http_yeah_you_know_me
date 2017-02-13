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

  def read_body socket, length
    {:body => socket.read(length)}
  end

  def build_request_hash
    @request_hash = {}
    original_request.each do |line|
      if line.length == 1
        request_hash.merge!(first_line_hash(line))
      elsif line[0] == "Host"
        request_hash[:host] = line[1].strip
        request_hash[:port] = line[2]
      else
        request_hash[line[0].strip.to_sym] = line[1].strip # Note that some terms that include - don't convert to symbols nicely
      end
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
    path_hash.merge!(params_hash(path))
  end

  def params_hash params
    key_vals = {}

    binding.pry
    params = params.split("&") if params.kind_of?(String)
    params.length.times do |i|
      key_val_tuple = params[i].split("=")
      key_vals[key_val_tuple[0].to_sym] = key_val_tuple[1]
    end
    {:params => key_vals}
  end
end
