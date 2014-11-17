require_relative 'network_interface'

class NetworkEntity
  def initialize *args
    @ports = {}
    args.each_slice(2) do |slice|
      @ports[slice[0]] = NetworkInterface.new(slice[1], slice[0]) if slice[1]
    end
  end

  # possivelmente vai ter os algoritmos de TCP aqui
  def tcp_send packet

  end

  # possivelmente vai ter a lógica de envio UDP aqui
  def udp_send packet

  end
end