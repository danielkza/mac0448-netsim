class SimulatorObject
  attr_reader :name, :simulator

  def initialize
    @name = nil
    @simulator = nil
  end

  def name=(name_)
    unless @name.nil?
      raise 'Cannot change name already set'
    end

    @name = name_
  end

  def simulator=(sim)
    unless @simulator.nil?
      raise 'Cannot change simulator already set'
    end

    @simulator = sim
  end
end
