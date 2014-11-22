require_relative 'network_interface'
require 'ipaddr'

class NetworkEntity
  def initialize num_ports
    @interfaces = {}
    (0...num_ports).each do |i|
      @interfaces[i] = NetworkInterface.new(self, num)
    end
    @routes = []
  end

  def add_interface num, ip
    @interfaces[num].ip = ip
  end

  # possivelmente vai ter os algoritmos de TCP aqui
  # def tcp_send packet
  #
  # end

  # possivelmente vai ter a lógica de envio UDP aqui
  # def udp_send packet
  #
  # end

  def add_route *args
    args.each_slice(2) do |slice|
      @routes << [IPAddr.new(slice[0]).mask(24), slice[1]]
    end
    @routes.sort! { |r1, r2| r2[0].to_i <=> r1[0].to_i }
  end

  def send_packet pkt
    send_packet_r pkt.dst, pkt
  end

  def send_packet_r dest_ip, pkt
    puts dest_ip
    ip = IPAddr.new(dest_ip, Socket::AF_INET)
    @routes.each do |r|
      if r[0].include? ip
        if @ports[r[1]]
          @ports[r[1]].send_packet pkt
        else
          send_packet_r r[1], pkt
        end
        break
      end
    end
  end
end