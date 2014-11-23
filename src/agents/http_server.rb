require_relative '../agent'

class Agents::HTTPServer < Agent
  def tick
    if @host.buffer[0]
      pkt = @host.buffer.shift
      f = File.open '../test.html', 'r'
      content = "HTTP/1.1 200 OK\n\n" + f.read
      @host.send_packet content, pkt.src
    end
  end
end