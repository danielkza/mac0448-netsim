require_relative 'network_entity'

class Router < NetworkEntity
  def initialize *args
    super(*args)
    @buffers = {}
    @capacities = {}
  end

  def set_processing_time time
    @processing_time = time
  end

  def set_capacity interface_num, capacity
    @buffers[interface_num] = []
    @capacities[interface_num] = capacity
  end

  def receive_packet interface_num, pkt
    @buffers[interface_num] << pkt
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
    send_packet_r IPAddr.new(pkt.dst, Socket::AF_INET), pkt
  end
end
