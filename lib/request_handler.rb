class RequestHandler

  attr_reader :original_request, :request_hash

  def initialize
    @original_request = []
    @request_hash = {}
  end

  def receive_request socket
    while line = socket.gets and !line.chomp.empty?
      puts "Reading request..."
      original_request << line.chomp.split(":")
    end
    original_request
  end

  def read_body socket, length
    request_hash[:body] = socket.read(length)
  end

  def build_request_hash
    original_request.each_with_index do |line, line_number|
      process_first_line(line[0]) if line_number == 0
      process_host_line(line) if line[0] == "Host"
      request_hash[line[0].strip.to_sym] = line[1].strip unless line_number == 0 || line[0] == "Host"
    end
  end

  def process_host_line line
    request_hash[:host] = line[1].strip
    request_hash[:port] = line[2]
  end

  def process_first_line line
    line = line.split(" ")
    request_hash[:verb] = line[0]
    process_path(line[1])
    request_hash[:protocol] = line[2]
  end

  def process_path path
    path = path.split("?") if path
    request_hash[:path] = path[0]
    request_hash[:params] = get_params(path[1])
  end

  def get_params params
    return request_hash[:params] = {} unless params.kind_of?(String)

    request_hash[:params] = {}
    params = params.split("?")
    params.each do |param|
      key_val_tuple = param.split("=")
      request_hash[:params][key_val_tuple[0].to_sym] = key_val_tuple[1]
    end
  end
end
