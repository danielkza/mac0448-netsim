require_relative '../agent'

class Agents::DNSServer < Agent
  def tick
    if @host.buffer[0]
      # query no formato 'A nome', pegando 'nome'
      pkt = @host.buffer.shift
      q = pkt.data.split[1]
      puts "q: #{q}"
      a = @host.simulator.host_ips[q]
      @host.send_packet "#{q} A #{a}", pkt.src
    end
  end
end