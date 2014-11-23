require 'pp'

require 'parslet'
require 'parslet/convenience'

module Input
  BANDWIDTH_UNITS = {
      'b' => 1, 'B' => 8,
      'Kb'  => 1000,   'Mb'  => 1000**2,   'Gb'  => 1000**3,
      'KB'  => 8*1000, 'MB'  => 8*1024**2, 'GB'  => 8*1024**3,
      'KiB' => 8*1024, 'MiB' => 8*1024**2, 'GiB' => 8*1024**3
  }
  TIME_UNITS = {
      '' => 1e6, 's' => 1e6, 'ms' => 1e3, 'us' => 1, 'μs' => 1
  }

  module_function

  def parse_input input
    parsed = NetsimParser.new.parse_with_debug(input)
    pp parsed
    puts ('*' * 80)
    transformed = NetsimTransform.new.apply(parsed)
    pp transformed
    parsed
  end

  def run_input input
    Input::State.new.run(parse_input(input))
  end
end

require_relative 'input/parser'
require_relative 'input/transform'
require_relative 'input/state'
