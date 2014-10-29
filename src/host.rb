require_relative 'network_entity'

class Host < NetworkEntity
  attr_reader :ip, :gateway, :dns, :agent

  def initialize ip, gateway, dns
    super ip
    @ip = ip
    @gateway = gateway
    @dns = dns
  end

  def interface
    @ports[0]
  end

  def attach_agent agent
    # provavelmente cada host vai ter só um
    @agent = agent
  end
end