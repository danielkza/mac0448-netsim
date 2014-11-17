require_relative 'host'
require_relative 'network_interface'

class Link
  # a e b são as interfaces dos dois lados do enlace
  def initialize a, b, capacity, delay
    @a = get_interface a
    @b = get_interface b
    @capacity = capacity
    @delay = delay
  end

  def get_interface entity
    if entity.is_a? Host
      entity.interface
    elsif entity.is_a? NetworkInterface
      entity
    else
      puts 'Error! Tried to set link with unknown entity'
      exit 1
    end
  end

  # Acopla um sniffer nesse enlace
  def attach_sniffer id, output
    @sniffer_id = id
    @sniffer_output = output
  end

  def tick
    # executa ações...

    # loga se tiver sniffer
    # if @sniffer_id
    #   File.open(@sniffer_output, 'a') do |f|
    #     f.puts "log from #{@sniffer_id}..."
    #   end
    # end
  end
end