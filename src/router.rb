require_relative 'network_entity'
require 'ipaddr'

class Router < NetworkEntity
  def initialize *args
    super *args
    @buffers = {}
    @capacities = {}
    @routes = []
  end

  def [] port
    @ports[port]
  end

  def set_performance processing_time, *args
    @processing_time = processing_time
    args.each_slice(2) do |slice|
      @buffers[slice[0]] = []
      @capacities[slice[0]] = slice[1]
    end
  end

  def add_route *args
    args.each_slice(2) do |slice|
      @routes << [slice[0], get_mask(slice[0]), slice[1]]
    end
    @routes.sort! { |r1, r2| r2[1] <=> r1[1] }
  end

  def send_packet port, pkt
    @buffers[port] << pkt
  end

  def tick
    @buffers.each_value do |v|
      process_packet v[0] if v[0]
    end
  end

  def process_packet pkt
    ip = pkt.dest.ip
    @routes.each do |r|
      if ip & r[1] == r[0]
        puts "pacote de #{pkt.src.ip} destino: #{r[2]}"
      end
    end
  end

  def get_mask str
    ip = IPAddr.new(str).to_i
    puts "ip: #{ip}"
    c = 0
    i = 0xff
    while c < 32
      break if ip & i > 0
      i << 8
      c += 8
    end
    0xffffffff - 2**c + 1
  end
end