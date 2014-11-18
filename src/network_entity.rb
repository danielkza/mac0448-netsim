require_relative 'network_interface'

class NetworkEntity
  def initialize *args
    @ports = {}
    args.each_slice(2) do |slice|
      @ports[slice[0]] = NetworkInterface.new(self, slice[1], slice[0]) if slice[1]
    end
    @routes = []
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
      @routes << [IPAddr.new(slice[0]).to_i, get_mask(slice[0]), slice[1]]
    end
    @routes.sort! { |r1, r2| r2[1] <=> r1[1] }
  end

  def send_packet dest_ip, content
    ip = IPAddr.new(dest_ip).to_i
    @routes.each do |r|
      if ip & r[1] == r[0]
        if r[2].is_a? String
          send_packet r[2], content
        else
          @ports[r[2]].send_packet content
        end
        break
      end
    end
  end

  def get_mask ip_str
    ip = IPAddr.new(ip_str).to_i
    c = 0
    i = 0xff
    while c < 32
      break if ip & i > 0
      i <<= 8
      c += 8
    end
    0xffffffff - 2**c + 1
  end
end