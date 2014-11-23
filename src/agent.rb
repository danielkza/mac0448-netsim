require_relative 'simulator_object'

class Agent < SimulatorObject
  attr_reader :host

  def initialize *args
    super(*args)
    @host = nil
  end

  def host= host
    if @host != host
      raise 'Cannot change host already set for Agent' if @host
      @host = host
      # host.simulator.add(self)
    end
  end

  def run_action cmd
    puts "#{self.name} agent executing: #{cmd}"
  end
end
