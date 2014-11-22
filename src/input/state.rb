require 'pp'

require_relative '../simulator'
require_relative '../host'
require_relative '../router'

class Input::State
  def initialize
    @identifiers = {}
    @identifiers['simulator'] = Simulator.new
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

  def get_object identifier, type
    obj = @identifiers[identifier]

    if obj.nil?
      raise "Unknown or unset variable $#{identifier}"
    elsif ! obj.is_a?(type)
      raise "Variable $#{identifier} has wrong type (should be #{type.name})"
    end

    obj
  end

  def assignment identifier: req_arg, initializer: reg_arg
    identifier = identifier.to_s

    if @identifiers.key?(identifier)
      raise "Name #{identifier} already assigned"
    end

    init_action = initializer.keys[0]
    init_params = initializer[init_action]

    if init_action == :new_call
      case init_params[:type]
        when 'Simulator'
          @identifiers[identifier.to_s] = Simulator.new
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
      @identifiers[identifier] = value
    end
  end

  def create_link simulator: req_arg, left: req_arg, right: req_arg,
                  bandwidth: req_arg, delay: req_arg
    def get_interface opts
      type = opts.keys[0]

      ent = get_object(opts[type][:identifier], NetworkEntity)
      port =  if type == :router
        opts[:port]
      else # type == :host
        0
      end

      ent.interfaces[port]
    end

    left_iface = get_interface(left)
    right_iface = get_interface(right)

    link = Link.new(left_iface, right_iface, bandwidth, delay)
    simulator.add(link)
  end

  def configure_host simulator: req_arg, host: req_arg, ip: req_arg,
                     gateway: req_arg, dns: req_arg
    host = get_object(host[:identifier], Host)
    host.config(ip, dns, gateway)
  end

  def configure_router_ports simulator: req_arg, router: req_arg, ports: req_arg
    router = get_object(router[:identifier], Router)
    ports.each do |port|
      router.add_interface(port[:port], port[:ip])
    end
  end

  def configure_router_routes simulator: req_arg, router: req_arg, routes: req_arg
    router = get_object(router[:identifier], Router)
    routes.each do |route|
      ip = route[:ip]
      if ip
        router.
      end

    end
  end

  def run tree
    tree = tree.map(&method(:cleanup!))
    tree.each do |statement|
      action = statement.keys[0]
      params = statement[action]

      if respond_to?(action)
        puts action.to_s

        if statement.key?(:simulator)
          send(action, simulator: @identifiers[statement[:simulator]], **params)
        else
          send(action, **params)
        end
      else
        raise "Unknown action #{action.to_s}"
      end

      pp @identifiers
    end
  end

end
