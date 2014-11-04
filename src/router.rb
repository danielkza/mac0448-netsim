require_relative 'network_entity'

class Router < NetworkEntity
  def initialize *args
    super *args
  end

  def set_performance processing_time, *args
    @processing_time = processing_time
    @buffers = []
    @capacities = []
    (0...@ports.size).each do |i|
      @buffers << []
      @capacities << args[i]
    end
  end

  def [] port
    @ports[port]
  end

  # precisa entender os parâmetros para criação de rota no arquivo de entrada...
  def add_route
    # aqui são criadas instâncias de Link
  end

  def tick
    # atualiza timer do delay
    # verifica pacotes das interfaces e envia

    # @ports.each do |p|
    #   puts "port #{p.ip}, cap #{@capacities[p.port]}"
    # end
  end
end