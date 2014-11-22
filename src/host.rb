require_relative 'network_entity'

class Host < NetworkEntity
  attr_reader :ip, :gateway, :dns, :agent

  def initialize ip, gateway, dns
    super 0, ip
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

  def send_packet dest_ip, content
    pkt = Packet.new(@ip, 0, dest_ip, 0, content)
    interface.send_packet pkt
  end

  def receive_packet port, pkt
    puts "#{@ip}: recebi #{pkt.content}"
  end
end