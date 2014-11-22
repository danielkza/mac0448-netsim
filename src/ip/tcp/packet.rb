require 'bindata'

class IP::TCP::Packet < BinData::Record
  class << self
    def name
      "TCPPacket"
    end
  end

  FIN_MASK = 1 << 0
  SYN_MASK = 1 << 1
  RST_MASK = 1 << 2
  ACK_MASK = 1 << 4

  uint16 :src_port
  uint16 :dst_port
  uint32 :seq_num
  uint32 :ack_num
  bit4   :data_offset, :value => lambda { header_bytes / 4 }
  bit12  :flags
  uint16 :window_size
  uint16 :checksum
  uint16 :urgent_pointer
  string :data, :read_length => lambda { total_length - header_bytes }

  def fin
    flags & FIN_MASK != 0
  end

  def fin= val
    flags &= ~FIN_MASK
    flags |= FIN_MASK if val
  end

  def ack
    flags & ACK_MASK != 0
  end

  def ack= val
    flags &= ~ACK_MASK
    flags |= ACK_MASK if val
  end

  def syn
    flags & SYN_MASK != 0
  end

  def syn= val
    flags &= ~SYN_MASK
    flags |= SYN_MASK if val
  end

  def header_bytes
    data.rel_offset
  end

  def options_bytes
    header_bytes - 20
  end

  def calc_checksum
    csum = src_port + dst_port
    csum += (seq_num & 0xFFFF) + (seq_num >> 16)
    csum += (ack_num & 0xFFFF) + (ack_num >> 16)
    csum += (data_offset << 12) + flags
    csum += window_size
    csum += urgent_pointer
    csum = (csum & 0xFFFF) + ((csum & 0xF0000) >> 16)
    ~csum & 0xFFFF
  end
end
