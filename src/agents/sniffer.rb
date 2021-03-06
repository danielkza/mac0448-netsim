require_relative '../agent'

class Agents::Sniffer < Agent
  attr_accessor :log_file_name

  def initialize *args
    super(*args)
    @link = nil
    @log_file_name = nil
    @log_file = nil
  end

  def link= link
    if @link != link
      raise 'Cannot change link already set for Sniffer' if @link
      @link = link
      link.simulator.add(self)
    end
  end

  def prepare
    @log_file = File.open(@log_file_name, 'a')
    write_log_header
  end

  def log pkt
    @log_file.write "*** Packet #{pkt.id} captured by sniffer #{@name} ***\n" +
                    "- Source IP: #{IPAddr.new(pkt.src, Socket::AF_INET)}\n" +
                    "- Destination IP: #{IPAddr.new(pkt.dst, Socket::AF_INET)}\n" +
                    "==========================\n" +
                    "Contents:\n" + pkt.data + "\n\n"
  end

  protected

  def write_log_header
  end
end
