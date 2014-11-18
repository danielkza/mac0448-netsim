require_relative 'network_entity'
require 'ipaddr'

class Router < NetworkEntity
  def initialize *args
    super *args
    @buffers = {}
    @capacities = {}
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

  def receive_packet port, pkt
    @buffers[port] << pkt
  end

  def tick
    @buffers.each_value do |v|
      if v[0]
        process_packet v[0]
        v.shift
      end
    end
  end

  def process_packet pkt
    puts "processando #{pkt.src.ip}:#{pkt.src.port} -> #{pkt.dest.ip}:#{pkt.dest.port}"
  end
end