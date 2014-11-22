class NetworkInterface
  attr_accessor :link

  def initialize entity, num
    @entity = entity
    @num = num
    @link = nil
  end

  def send_packet pkt
    if @link
      @link.transport self, pkt
    else
      puts 'Não conectado!'
    end
  end

  def receive_packet pkt
    @entity.receive_packet @num, pkt
  end
end