class NetworkInterface
  attr_reader :ip, :port
  attr_accessor :link

  def initialize entity, ip, port
    @entity = entity
    @ip = ip
    @port = port
    @link = nil
  end

  def send_packet content
    if @link
      @link.transport self, content
    else
      puts 'Não conectado!'
    end
  end

  def receive_packet pkt
    @entity.receive_packet @port, pkt
  end
end