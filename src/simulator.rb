require_relative 'config'

class Simulator
  def initialize
    @time = 0

    # @sniffers é um vetor com chaves do hash @links, referenciando os links que
    # possuem um sniffer acoplado.
    @sniffers = []
    @links = {}

    # provavelmente aqui seriam iniciados os hosts e roteadores...
  end

  def tick
    # várias coisas aqui...

    # Imprimindo a saída de todos os sniffers
    @sniffers.each do |s|
      @links[s].output
    end

    @time += Config::SIM_TICK
  end
end