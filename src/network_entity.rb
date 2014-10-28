require_relative 'network_interface'

class NetworkEntity
  def initialize *args
    @ports = []
    args.each_with_index do |a, i|
      @ports << NetworkInterface.new(a, i)
    end
  end

  # possivelmente vai ter os algoritmos de TCP aqui
  def tcp_send packet

  end

  # possivelmente vai ter a lógica de envio UDP aqui
  def udp_send packet

  end
end