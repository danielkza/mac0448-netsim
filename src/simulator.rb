require_relative 'config'
require_relative 'link'
require_relative 'host'
require_relative 'router'
require_relative 'agent'

Action = Struct.new :command, :args

class Simulator
  def initialize
    @time = 0
    @actions = {}
    @links = []
    @agents = []
    @routers = []
  end

  def add *entity
    entity.each do |e|
      if e.is_a? Link; @links << e
      elsif e.is_a? Host; @agents << e.agent
      elsif e.is_a? Router; @routers << e
      else; puts 'Error! Unknown entity.'; end
    end
  end

  def at time, command, args = ''
    @actions[time] = Action.new command, args
    self
  end

  def tick
    if @actions[@time]
      parse_action
    end
    @links.each do |l|
      l.tick
    end
    @agents.each do |a|
      a.tick
    end
    @routers.each do |r|
      r.tick
    end

    @time += SimConfig::SIM_TICK
  end

  def parse_action
    cmd = @actions[@time].command
    if cmd == 'finish'
      puts 'Finishing simulation.'
      exit 0
    elsif cmd.is_a? Agent
      cmd.execute @actions[@time].args
    else
      puts 'Error! Unknown command.'
    end
  end
end