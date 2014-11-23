require 'awesome_print'

require_relative '../simulator'
require_relative '../host'
require_relative '../router'
require_relative '../agent'
require_relative '../agents'

class Input::State
  def initialize
    @identifiers = {}
    @identifiers['simulator'] = Simulator.new.tap { |s| s.name = 'simulator' }
    @links = {}
  end

  def run tree
    tree = tree.map(&method(:cleanup!))
    tree.each do |statement|
      action = statement.keys[0]
      params = statement[action]

      if respond_to?(action)
        if statement.key?(:simulator)
          send(action, simulator: @identifiers[statement[:simulator]], **params)
        elsif action != :comment
          send(action, **params)
        end
      else
        raise "Unknown action #{action.to_s}"
      end
    end
  end

  def get_object identifier, type
    obj = @identifiers[identifier]

    if obj.nil?
      raise "Unknown or unset variable $#{identifier}"
    elsif ! obj.is_a?(type)
      raise "Variable $#{identifier} has wrong type (should be #{type.name})"
    end

    obj
  end

  def comment *args
  end

  def assignment identifier: req_arg, initializer: req_arg
    identifier = identifier.to_s

    if @identifiers.key?(identifier)
      raise "Name #{identifier} already assigned"
    end

    init_action = initializer.keys[0]
    init_params = initializer[init_action]

    value = if init_action == :new_call
      case init_params[:type]
        when 'Simulator'
          Simulator.new
        when 'Agent/Sniffer'
          Agents::Sniffer.new
        when 'Agent/HTTPClient'
          raise 'HTTPClient not implemented yet'
        when 'Agent/HTTPServer'
          raise 'HTTPServer not implemented yet'
        when 'Agent/DNSServer'
          raise 'DNSServer not implemented yet'
        else
          raise "Unknown object type #{init_params[:type]}"
      end
    elsif init_action == :simulator_call
      simulator_id = init_params[:identifier]

      sim = get_object(simulator_id, Simulator)
      value = case init_params[:method]
        when 'host'
          Host.new
        when 'router'
          Router.new(init_params[:port_count])
        else
          raise "Unknown simulator method #{init_params[:method]}"
      end

      sim.add(value)
      value
    end

    value.name = identifier
    @identifiers[identifier] = value

    puts "set: #{identifier} := #{value.class.name}"
  end

  def create_link simulator: req_arg, left: req_arg, right: req_arg,
                  bandwidth: req_arg, delay: req_arg
    ports = [get_interface(left), get_interface(right)]

    in_use = ports.find { |v| @links.key?(v) }
    if in_use
      raise "Cannot create link for port already in use: #{in_use}"
    end

    link = Link.new(*(ports.map(&:iface)), bandwidth, delay)
    simulator.add(link)

    ports.each { |p| @links[p] = link }
    puts "create_link: #{ports[0]} <-> #{ports[1]}"
  end

  def configure_host simulator: req_arg, host: req_arg, ip: req_arg,
                     gateway: req_arg, dns: req_arg
    host = get_object(host[:identifier], Host)
    host.config(ip, dns, gateway)

    puts "configure_host: #{host.name} ip = #{ip}, gateway = #{gateway}, dns = {dns}"
  end

  def configure_router_ports simulator: req_arg, router: req_arg, ports: req_arg
    router = get_object(router[:identifier], Router)
    ports.each do |port|
      port, ip = port[:port], port[:ip]
      router.add_interface(port, ip)
      puts "configure_port: #{router.name}.#{port} = #{ip}"
    end
  end

  def configure_router_routes simulator: req_arg, router: req_arg,
                              routes: req_arg
    router = get_object(router[:identifier], Router)
    routes.each do |route|
      target = route[:target]
      unless target
        raise 'Invalid route target'
      end

      ip = route[:gateway]
      if ip
        router.add_route_ip(target, ip)
        puts "configure_route: #{router.name}, #{target} via #{ip}"
      else
        port = route[:port]
        unless port
          raise 'Route has no destination'
        end

        router.add_route_port(target, port)
        puts "configure_route: #{router.name}, #{target} port #{port}"
      end
    end
  end

  def configure_router_performance simulator: req_arg, router: router,
                                   delay: req_arg, queue_sizes: req_arg
    router = get_object(router[:identifier], Router)

    router.set_processing_time(delay)
    puts "configure_processing_time: #{router.name} #{delay}"

    queue_sizes.each do |queue_size|
      port, capacity = queue_size[:port], queue_size[:queue_size]
      router.set_capacity(port, capacity)
      puts "configure_capacity: #{router.name}.#{port} = #{capacity}"
    end
  end

  def attach_agent simulator: req_arg, agent: req_arg, host: req_arg
    agent = get_object(agent[:identifier], Agent)
    host = get_objecct(host[:identiifier], Host)

    host.attach_agent(agent)
    puts "attach_agent: #{host.name} <= #{agent.name}"
  end

  def attach_sniffer simulator: req_arg, sniffer: req_arg, port1: req_arg,
                     port2: req_arg, log_file: req_arg
    sniffer = get_object(sniffer[:identifier], Agents::Sniffer)

    port1, port2 = [port1, port2].map { |p| get_interface(p) }
    link1, link2 = [port1, port2].map { |p| @links[p] }

    missing = if link1.nil?
      port1
    elsif link2.nil?
      port2
    end

    if missing
      raise "Cannot attach sniffer to port #{port} that has no link attached"
    elsif link1 != link2
      raise "Cannot attach sniffer to ports with different links: #{port1}, #{port2}"
    end

    link1.attach_sniffer(sniffer)
    puts "attach_sniffer: #{sniffer.name} <= #{port1} <-> #{port2}"
  end

  def schedule_action simulator: req_arg, time: req_arg, action: req_arg
    agent, *cmd = action.split(' ')
    if cmd.empty?
      cmd = agent
      simulator.add_simulator_action(time, cmd)
      puts "simulator action: $#{simulator.name} at #{time} do #{cmd}"
    else
      agent = get_object(agent, Agent)

      simulator.add_action(time, agent, cmd)
      puts "schedule_action: $#{agent.name} at #{time} do #{cmd}"
    end
  end

  protected

  Interface = Struct.new(:ent, :port) do
    def to_s
      "#{ent.name}.#{port}"
    end

    def iface
      ent[port]
    end
  end

  def req_arg
    raise 'Missing argument for action'
  end

  def cleanup! hash
    hash.each do |key, value|
      if value.is_a?(Parslet::Slice)
        hash[key] = value.to_s
      elsif value.is_a?(Hash)
        cleanup!(value)
      end
    end

    hash
  end

  def get_interface opts
    type = opts.keys[0]

    ent = get_object(opts[type][:identifier], NetworkEntity)
    port =  if type == :router
      opts[:port]
    else # type == :host
      0
    end

    Interface.new(ent, port)
  end
end
