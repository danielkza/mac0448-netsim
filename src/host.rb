require_relative 'network_entity'

class Host < NetworkEntity
  attr_reader :ip, :gateway, :dns, :agent

  def initialize
    super 1
  end

  def config ip, dns, gateway
    @ip = ip
    @dns = dns
    add_interface 0, ip
    add_route_ip '0.0.0.0', gateway, 0
    add_route_port gateway, 0
  end

  def attach_agent agent
    # provavelmente cada host vai ter só um
    @agent = agent
  end

  def receive_packet interface_num, pkt
    puts "#{@ip}: recebi #{pkt.data}"
  end
end
