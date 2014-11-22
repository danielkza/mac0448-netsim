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

  def set_performance processing_time, *args
    @processing_time = processing_time
    args.each_slice(2) do |slice|
      @buffers[slice[0]] = []
      @capacities[slice[0]] = slice[1]
    end
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
    puts "processando #{pkt.data}"
  end
end