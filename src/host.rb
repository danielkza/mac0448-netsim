require_relative 'network_entity'

class Host < NetworkEntity
  attr_reader :ip, :gateway, :dns

  def initialize ip, gateway, dns
    super ip
    @ip = ip
    @gateway = gateway
    @dns = dns
  end

  def attach_agent agent
    # provavelmente cada host vai ter só um
    @agent = agent
  end
end