require_relative 'host'
require_relative 'network_interface'

class Link
  # a e b são as interfaces dos dois lados do enlace
  def initialize a, b, capacity, delay
    @a = a
    @b = b
    @a.link = @b.link = self
    @capacity = capacity
    @delay = delay
    @to_a = []
    @to_b = []
  end

  # Acopla um sniffer nesse enlace
  def attach_sniffer id, output
    @sniffer_id = id
    @sniffer_output = output
  end

  # Usado pela interface numa ponta para solicitar o transporte para a outra ponta
  def transport sender, pkt
    if sender == @a
      @to_b << pkt
    else
      @to_a << pkt
    end
  end

  def tick
    if @to_a[0]
      @a.receive_packet @to_a[0]
      @to_a.shift
    elsif @to_b[0]
      @b.receive_packet @to_b[0]
      @to_b.shift
    end

    # loga se tiver sniffer
    # if @sniffer_id
    #   File.open(@sniffer_output, 'a') do |f|
    #     f.puts "log from #{@sniffer_id}..."
    #   end
    # end
  end
end
