require_relative 'network_entity'

class Host < NetworkEntity
  attr_reader :ip, :gateway, :dns, :agent

  def initialize ip, gateway, dns
    super 0, ip
    @ip = ip
    @gateway = gateway
    @dns = dns
    add_route '0.0.0.0', 0
  end

  def interface
    @ports[0]
  end

  def attach_agent agent
    # provavelmente cada host vai ter só um
    @agent = agent
  end

  def receive_packet port, pkt
    puts "#{@ip}: recebi #{pkt.content}"
  end
end