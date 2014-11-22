require_relative 'link'
require_relative 'host'
require_relative 'router'
require_relative 'agent'

Action = Struct.new(:command, :args)

class Simulator < SimulatorObject
  # Maximum segment size
  IP_MSS = 1460

  # Intervalo entre cada passo da simulação, em microssegundos
  SIM_TICK = 100

  def initialize
    super
    @time = 0
    @frame = 0
    @actions = {}
    @links = []
    @hosts = []
    @routers = []
    @agents = []
  end

  def add *entity
    entity.each do |e|
      e.simulator = self

      if e.is_a? Link; @links << e
      elsif e.is_a? Host; @hosts << e
      elsif e.is_a? Router; @routers << e
      elsif e.is_a? Agent; @agents << e
      else; raise 'Error! Unknown entity.'; end
    end
  end

  def at time, command, args = ''
    key = ((time * 1000000) / SIM_TICK).ceil
    @actions[key] = [] if @actions[key].nil?
    @actions[key] << Action.new(command, args)
    self
  end

  def tick
    if @actions[@frame]
      parse_actions
    end
    @links.each do |l|
      l.tick
    end
    @hosts.each do |a|
      a.agent.tick if a.agent
    end
    @routers.each do |r|
      r.tick
    end

    @time += SimConfig::SIM_TICK
    @frame += 1
  end

  def parse_actions
    @actions[@frame].each do |action|
      cmd = action.command
      if cmd == 'finish'
        puts 'Finishing simulation.'
        exit 0
      elsif cmd.is_a? Agent
        cmd.execute action.args
      else
        puts 'Error! Unknown command.'
      end
    end
  end
end
