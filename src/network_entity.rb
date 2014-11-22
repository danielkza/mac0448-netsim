require 'ipaddr'
require 'socket'

require_relative 'simulator_object'
require_relative 'network_interface'
require_relative 'ip'

class NetworkEntity < SimulatorObject
  attr_accessor :name

  def initialize num_ports, *args
    super(*args)

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

  def [] num
    @interfaces[num]
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

  def add_route_ip target, destination, mask = 24
    @routes << [route_target(target, mask),
                IPAddr.new(destination, Socket::AF_INET)]
    sort_routes!
  end

  def add_route_port target, port, mask = 24
    @routes << [route_target(target, mask), port]
    sort_routes!
  end

  def send_packet content, dest
    pkt = IP::Packet.new(version: 4, dscp: 0, ecn: 0, id: 0xda00,
                         flags: 0x02, frag_offset: 0, ttl: 64,
                         protocol: IP::Packet::PROTO_UDP,
                         src: IPAddr.new(@ip).to_i, dst: IPAddr.new(dest).to_i, data: content)
    send_packet_r IPAddr.new(pkt.dst, Socket::AF_INET), pkt
  end

  def send_packet_r dest_ip, pkt
    puts "#{@name} #{dest_ip}"
    @routes.each do |r|
      puts "#{r[0]} #{r[1]}"
      if r[0].include? dest_ip
        if @interfaces[r[1]]
          @interfaces[r[1]].send_packet pkt
        else
          send_packet_r r[1], pkt
        end
        break
      end
    end
  end

  protected

  def route_target ip, mask
    IPAddr.new("#{ip}/#{mask}", Socket::AF_INET).mask(mask)
  end

  def sort_routes!
    @routes.sort! { |r1, r2| r2[0].to_i <=> r1[0].to_i }
  end

end
