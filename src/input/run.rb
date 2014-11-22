require_relative '../simulator'
require_relative '../host'
require_relative '../router'

class Input::State
  def initialize
    @identifiers = {}
  end

  def req_arg
    raise 'Missing argument for action'
  end

  def run tree
    identifiers = {}

    # @type statement [Hash]
    tree.each do |statement|
      action = statement.keys[0]
      params = statement[action]

      if respond_to?(action)
        send(action, **params)
      else
        raise "Unknown action #{action.to_s}"
      end
    end
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

      unless @identifiers.key?(identifier)
        puts "Creating simulator $#{identifier}"
        @identifiers[identifier] = Simulator.new
      end

      unless @identifiers[identifier].is_a?(Simulator)
        raise 'Tried to call non-Simulator'
      end

      value = case init_params[:method]
        when 'host'
          Host.new(nil, nil, nil)
        when 'router'
          Router.new(nil, nil, nil, init_params[:port_count])
        else
          raise "Unknown simulator method #{init_params[:method]}"
      end

      @identifiers[identifier] = value
    end
  end

  def create_link left: req_arg, right: req_arg, bandwidth: req_arg,
                  delay: req_arg
    

  end
end
