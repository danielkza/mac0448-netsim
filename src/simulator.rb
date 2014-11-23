require_relative 'link'
require_relative 'host'
require_relative 'router'
require_relative 'agents'

Action = Struct.new(:agent, :command)

class Simulator < SimulatorObject
  # Maximum segment size
  IP_MSS = 1460

  # Intervalo entre cada passo da simulação, em microssegundos
  SIM_TICK = 100

  attr_reader :host_ips

  def initialize
    super
    @time = 0
    @frame = 0
    @actions = {}
    @links = []
    @hosts = []
    @routers = []
    @finished = false
    @host_ips = {}
  end

  def add *entity
    entity.each do |e|
      e.simulator = self

      if e.is_a? Link; @links << e
      elsif e.is_a? Host; @hosts << e
      elsif e.is_a? Router; @routers << e
      elsif e.is_a? Agent;
      else; raise 'Error! Unknown entity.'; end
    end
  end

  def add_action time, agent, command
    key = (time / SIM_TICK).ceil
    @actions[key] = [] if @actions[key].nil?
    @actions[key] << Action.new(agent, command)
    self
  end

  def add_simulator_action time, command
    add_action(time, self, command)
  end

  def run_action cmd
    if cmd == 'finish'
      @finished = true
      exit 0
    end
  end

  def tick
    if @actions[@frame]
      run_frame_actions(@frame)
    end

    @links.each do |l|
      l.tick
    end

    @hosts.each do |h|
      h.tick
    end

    @routers.each do |r|
      r.tick
    end

    @time += SIM_TICK
    @frame += 1
  end

  def run_frame_actions(frame)
    @actions[frame].each do |action|
      action.agent.run_action(action.command)
    end
  end
end
