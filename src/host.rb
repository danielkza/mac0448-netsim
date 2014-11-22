require_relative 'network_entity'

class Host < NetworkEntity
  attr_reader :ip, :gateway, :dns, :agent

  def initialize(*args)
    super(1, *args)
    @ip = nil
    @dns = nil
    @gateway = nil
    @agent = nil
  end

  def config ip, dns, gateway
    @ip = ip
    @dns = dns
    add_interface 0, ip
    add_route_ip '0.0.0.0', gateway, 0
    add_route_port gateway, 0
  end

  def attach_agent agent
    if @agent != agent
      raise 'Cannot change host already set for Agent' if @agent

      @agent = agent
      agent.host = self
    end
  end

  def receive_packet interface_num, pkt
    puts "#{@ip}: recebi #{pkt.data}"
  end
end
