require_relative '../agent'

class Agents::Sniffer < Agent
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

  protected

  def write_log_header
  end
end
