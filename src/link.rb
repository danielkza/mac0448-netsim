require_relative 'simulator_object'
require_relative 'host'
require_relative 'network_interface'

class Link < SimulatorObject
  attr_reader :a, :b, :capacity, :delay, :sniffer

  # a e b são as interfaces dos dois lados do enlace
  def initialize a, b, capacity, delay, *args
    super(*args)

    @a = a
    @b = b
    @capacity = capacity
    @delay = delay
    @to_a = []
    @to_b = []
    @sniffer = nil

    @a.link = self
    @b.link = self
  end

  # Acopla um sniffer nesse enlace
  def attach_sniffer sniffer
    if @sniffer != sniffer
      raise 'Cannot change sniffer already set for Link' if @agent

      @sniffer = sniffer
      sniffer.link = self
    end
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
      @sniffer.log @to_a.shift if @sniffer
    elsif @to_b[0]
      @b.receive_packet @to_b[0]
      @sniffer.log @to_b.shift if @sniffer
    end
  end
end
