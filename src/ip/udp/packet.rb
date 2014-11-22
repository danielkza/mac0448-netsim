require 'bindata'

class IP::UDP::Packet < BinData::Record
  class << self
    def name
      "UDPPacket"
    end
  end

  uint16 :src_port
  uint16 :dst_port
  uint16 :length, :value => :num_bytes
  uint16 :checksum, :value => lambda { 0 }

  string :data, :read_length => lambda { length - header_bytes }

  def header_bytes
    data.rel_offset
  end
end
