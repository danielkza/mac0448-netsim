require_relative 'network_entity'

class Router < NetworkEntity
  def initialize num_interfaces
    super
    @buffers = {}
    @capacities = {}
  end

  def [] num
    @interfaces[num]
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
    puts "processando pacote"
    send_packet pkt
  end
end