require_relative 'network_interface'
require 'ipaddr'

class NetworkEntity
  attr_reader :interfaces
  attr_accessor :name

  def initialize num_ports
    @interfaces = {}
    (0...num_ports).each do |i|
      @interfaces[i] = NetworkInterface.new(self, i)
    end
    @routes = []
    @name = nil
  end

  def add_interface num, ip
    @interfaces[num].ip = ip
  end

  def prepare
    @interfaces.each do |k, v|
      if v.link
        if v == v.link.a
          add_route_port v.link.b.ip, k, 32
        else
          add_route_port v.link.a.ip, k, 32
        end
      end
    end
  end

  # possivelmente vai ter os algoritmos de TCP aqui
  # def tcp_send packet
  #
  # end

  # possivelmente vai ter a lógica de envio UDP aqui
  # def udp_send packet
  #
  # end

  def sort_routes!
    @routes.sort! { |r1, r2| r2[0].to_i <=> r1[0].to_i }
  end

  def add_route_ip target, destination, mask = 24
    @routes << [IPAddr.new("#{target}/#{mask}").mask(mask), IPAddr.new(destination)]
    sort_routes!
  end

  def add_route_port target, port, mask = 24
    @routes << [IPAddr.new("#{target}/#{mask}").mask(mask), port]
    sort_routes!
  end

  def send_packet pkt
    send_packet_r pkt.dst, pkt
  end

  def send_packet_r dest_ip, pkt
    ip = IPAddr.new(dest_ip, Socket::AF_INET)
    @routes.each do |r|
      if r[0].include? ip
        if @interfaces[r[1]]
          @interfaces[r[1]].send_packet pkt
        else
          send_packet_r r[1], pkt
        end
        break
      end
    end
  end
end
