class Agent
  def initialize type
    @type = type
  end

  def execute args
    puts "#{@type} agent executing: #{args}"
  end

  def tick
    # puts "#{@type} agent acting..."
  end
end