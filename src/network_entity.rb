require_relative 'network_interface'
require 'ipaddr'

class NetworkEntity
  def initialize num_ports
    @interfaces = {}
    (0...num_ports).each do |i|
      @interfaces[i] = NetworkInterface.new(self, i)
    end
    @routes = []
  end

  def add_interface num, ip
    i = @interfaces[num]
    i.ip = ip
    if i.link
      if i == link.a
        add_route i.link.b.ip, num
      else
        add_route i.link.a.ip, num
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

  def add_route *args
    args.each_slice(2) do |slice|
      @routes << [IPAddr.new("#{slice[0]}/24").mask(24), slice[1]]
    end
    @routes.sort! { |r1, r2| r2[0].to_i <=> r1[0].to_i }
    puts "#{@ip}: "
    p @routes
  end

  def send_packet pkt
    send_packet_r pkt.dst, pkt
  end

  def send_packet_r dest_ip, pkt
    puts dest_ip
    ip = IPAddr.new(dest_ip, Socket::AF_INET)
    @routes.each do |r|
      puts "ip: #{ip}, r: #{r[0]}"
      if r[0].include? ip
        if @interfaces[r[1]]
          puts 'enviando'
          @interfaces[r[1]].send_packet pkt
        else
          puts 'encaminhando'
          send_packet_r r[1], pkt
        end
        break
      end
    end
  end
end