require_relative '../agent'

class DNSServer < Agent
  def tick
    if @host.buffer[0]
      # query no formato 'A nome', pegando 'nome'
      q = @host.buffer.shift.data.split[1]
      a = @simulator.host_ips[q]
      @host.send_packet "#{q} A #{a}"
    end
  end
end