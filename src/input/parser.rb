require 'parslet'

# HACK
class BlankSlate
  def nil?
    false
  end

  reveal(:nil?)
  reveal(:is_a?)
end

module Input
  class StringParser < Parslet::Parser
    rule(:quote)    { str(?") }
    rule(:nonquote) { str(?").absnt? >> any.as(:char) }
    rule(:escape)   { str('\\') >> any.as(:char) }
    rule(:string) {
      quote >> (escape | nonquote).repeat(1).as(:str) >> quote
    }
    root :string
  end

  class StringTransform < Parslet::Transform
    rule(:str => sequence(:chars)) { chars.join }
    rule(:esc => simple(:c)) { c }
  end

  class NetsimParser < Parslet::Parser
    def any_of strs
      strs.map(&method(:str)).reduce(:|)
    end

    def rule_as_self sym
      send(sym).as(sym)
    end

    # Whitespace
    rule(:space)    { match('[^\S\n]').repeat(1) }
    rule(:space?)   { space.maybe }
    rule(:line_end) { (space? >> str("\n")).repeat(1) | any.absent? }

    # Basic matchers
    rule(:digit)    { match('[0-9]') }
    rule(:digits)   { digit.repeat(1) }
    rule(:integer)  { digits.as(:int) }
    rule(:float)    { (digits >> str('.') >> digits).as(:float) }
    rule(:number)   { float | integer }
    rule(:letter)   { match('[a-zA-Z]') }
    rule(:string)   { str(?") >> (str(?").absent? >> any).repeat(1) >> str(?") }

    # Unit/type matchers

    # 192.168.1.1 | 192.134.212.200 | 1.1.1.1
    rule(:ip) {
      (digit.repeat(1, 3) >> str('.')).repeat(3) >> digit.repeat(1, 3)
    }

    def bandwidth_unit
      any_of(Input::BANDWIDTH_UNITS.keys)
    end

    # 10Gbps | 2Mbps | 1000Kbps
    rule(:bandwidth) {
      number.as(:amount) >> bandwidth_unit.as(:bw_unit) >> str('ps')
    }

    def time_unit
      any_of(Input::TIME_UNITS.keys.sort_by { |k| -k.length })
    end

    # 0.1 | 10s | 10ms | 10us
    rule(:time) {
      number.as(:amount) >> time_unit.as(:time_unit)
    }

    # Variables
    # name
    rule(:identifier) {
      letter >> (letter | digit).repeat(0)
    }
    # $name
    rule(:identifier_ref) {
      str('$') >> identifier.as(:identifier)
    }
    # $name.1
    rule(:router_port_ref) {
      identifier_ref.as(:router) >> str('.') >> integer.as(:port)
    }
    # $name | $name.1
    rule(:port_ref) {
      router_port_ref | identifier_ref.as(:host)
    }

    # Call-with-result
    # $simulator host
    rule(:host_call_params) {
      str('host').as(:method)
    }
    # $simulator router 1
    rule(:router_call_params) {
      str('router').as(:method) >> space >> integer.as(:port_count)
    }
    # $simulator host | $simulator router 3
    rule(:simulator_call) {
      identifier_ref >> space >> (host_call_params | router_call_params)
    }
    # new Agent/HTTPServer
    rule(:new_call) {
      str('new') >> space >> (
        (str('Agent/') >> letter.repeat(1)) | str('Simulator')
      ).as(:type)

    }
    # [$simulator host] | [$simulator router 3] | [new Agent/HTTPClient]
    rule(:call_result) {
      str('[') >> space? >> (
        simulator_call.as(:simulator_call) | new_call.as(:new_call)
      ) >> space? >> str(']')
    }

    # Statements

    # set name [$simulator host]
    rule(:assignment) {
      str('set') >> space >> identifier.as(:identifier) >>
                    space >> call_result.as(:initializer)
    }
    # $simulator duplex-link $h0 $r1.0 10Mbps 10ms
    rule(:create_link) {
      str('duplex-link') >> space >> port_ref.as(:left) >>
                            space >> port_ref.as(:right) >>
                            space >> bandwidth.as(:bandwidth) >>
                            space >> time.as(:delay)
    }
    # $simulator $h0 10.0.0.1 10.0.0.2 192.168.1.1
    rule(:configure_host) {
      identifier_ref.as(:host) >> space >> ip.as(:ip) >>
                                  space >> ip.as(:gateway) >>
                                  space >> ip.as(:dns)
    }
    # $simulator $r0 0 10.0.0.2 1 10.1.1.2 2 192.168.3.3
    rule(:configure_router_ports) {
      identifier_ref.as(:router) >> (
        space >> integer.as(:port) >> space >> ip.as(:ip)
      ).repeat(1).as(:ports)
    }
    # $simulator $r0 route 10.0.0.0 0 10.1.1.0 1 192.168.3.0 2 192.168.2.0
    rule(:configure_router_routes) {
      identifier_ref.as(:router) >> space >> str('route') >> (
        space >> ip.as(:target) >> space >> (ip.as(:gateway) | integer.as(:port))
      ).repeat(1).as(:routes)
    }
    # $simulator $r0 performance 100us 0 1000 1 1000 2 1000
    rule(:configure_router_performance) {
      identifier_ref.as(:router) >> space >> str('performance') >>
                                    space >> time.as(:delay) >> (
        space >> integer.as(:port) >> space >> integer.as(:queue_size)
      ).repeat(1).as(:queue_sizes)
    }
    # $simulator attach-agent $httpc0 $h0
    rule(:attach_agent) {
      str('attach-agent') >> space >> identifier_ref.as(:agent) >>
                             space >> port_ref.as(:port)
    }
    # $simulator attach-agent $sniffer1 $r0.2 $r1.0 "/tmp/sniffer1"
    rule(:attach_sniffer) {
      str('attach-agent') >> space >> identifier_ref.as(:sniffer) >>
                             space >> port_ref.as(:port1) >>
                             space >> port_ref.as(:port2) >>
                             space >> string.as(:log_file)
    }

    # $simulator at 0.5 "httpc0 GET h2"
    rule(:schedule_action) {
      str('at') >> space >> time.as(:time) >> space >> string.as(:action)
    }


    rule(:configure_param) {
      identifier_ref.as(:simulator) >> space >> (
        %i(create_link configure_host configure_router_ports
           configure_router_routes configure_router_performance attach_sniffer
           attach_agent schedule_action).map(&method(:rule_as_self)).reduce(&:|)
      ).as(:call)
    }

    # Statement
    rule(:comment) {
      str('#') >> (line_end.absent? >> any).repeat(0).as(:comment) >> line_end
    }
    rule(:statement)  {
      (assignment.as(:assignment) | configure_param).as(:statement) >> line_end
    }
    rule(:statements) {
      # Ensure at least one statement is present
      comment.repeat(0) >> statement.repeat(1) >> (statement | comment).repeat(0)
    }

    root :statements
  end
end
