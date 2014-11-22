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
      host.simulator.add(self)
    end
  end

  def execute args
    puts "#{self.class.name} agent executing: #{args}"
  end

  def tick
    # puts "#{@type} agent acting..."
  end
end
