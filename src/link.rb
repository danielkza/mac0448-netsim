class Link
  # a e b são as interfaces dos dois lados do enlace
  def initialize a, b, capacity, delay
    @a = a
    @b = b
    @capacity = capacity
    @delay = delay
  end

  # Acopla um sniffer nesse enlace
  def attach_sniffer id, output
    @sniffer_id = id
    @sniffer_output = output
  end

  # Imprime eventos ocorridos no último tick. Só será chamado para os enlaces
  # que têm sniffer acoplado.
  def output
    File.open(@sniffer_output, 'a') do |f|
      # f.write ...
    end
  end
end