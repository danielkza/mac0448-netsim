# Representa um pacote IP
class Packet
  attr_reader :src, :dest, :content

  def initialize src, dest, content
    @src = src
    @dest = dest
    @content = content
  end
end