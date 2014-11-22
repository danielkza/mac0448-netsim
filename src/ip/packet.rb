require 'bindata'

module IP
end

class IP::Packet < BinData::Record
  class << self
    def name
      "IPPacket"
    end
  end

  VERSION = 4
  PROTO_TCP = 6
  PROTO_UDP = 17

  endian :big

  bit4   :version, :asserted_value => VERSION
  bit4   :header_length, :value => lambda { header_bytes / 4 }
  uint8  :dscp, :asserted_value => 0
  uint16 :total_length, :value => :num_bytes
  uint16 :id
  bit3   :flags
  bit13  :frag_offset
  uint8  :ttl
  uint8  :protocol
  uint16 :checksum, :value => :calc_checksum
  uint32 :src
  uint32 :dst
  string :options, :read_length => :options_bytes
  string :data, :read_length => lambda { total_length - header_bytes }

  def header_bytes
    data.rel_offset
  end

  def options_bytes
    header_bytes - 20
  end

  def calc_checksum
    csum = 0
    csum = (version << 12) + (header_length << 8) + dscp
    csum += total_length
    csum += id
    csum += (flags << 13) + frag_offset
    csum += (ttl << 8) + protocol
    csum += (src & 0xFFFF) + (src >> 16)
    csum += (dst & 0xFFFF) + (dst >> 16)

    csum = (csum & 0xFFFF) + ((csum & 0xF0000) >> 16)
    ~csum & 0xFFFF
  end
end

packet = IP::Packet.new(version: 4, dscp: 0, ecn: 0, id: 0xda00,
                        flags: 0x02, frag_offset: 0, ttl: 64,
                        protocol: IP::Packet::PROTO_UDP,
                        src: 0xc0a8016e, dst: 0xacdbc769, data: "\0" * 1410)
puts IP::Packet.bindata_name
puts packet.snapshot
puts packet.to_binary_s.each_byte.map { |b| b.to_s(16).rjust(2,'0') }.join

