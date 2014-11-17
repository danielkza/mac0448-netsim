require_relative 'network_interface'

# Representa um pacote IP
class Packet
  attr_reader :src, :dest

  def initialize src, dest
    @src = src
    @dest = dest
  end
end