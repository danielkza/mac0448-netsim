# Representa um pacote IP
class Packet
  attr_reader :src_ip, :src_port, :dest_ip, :dest_port, :content

  def initialize src_ip, src_port, dest_ip, dest_port, content
    @src_ip = src_ip
    @src_port = src_port
    @dest_ip = dest_ip
    @dest_port = dest_port
    @content = content
  end
end