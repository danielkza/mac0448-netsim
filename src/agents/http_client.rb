require_relative '../agent'

class HTTPClient < Agent
  def execute args
    a = args.split
    if a[0] != 'GET'
      puts 'Error'
    end
    if a[2]
      unless /HTTP\/\d\.\d/ =~ a[2]
        puts 'Error'
      end
    else
      args += ' HTTP/1.1'
    end
    begin
      ip = IPAddr.new a[1]
      @host.send_packet args, a[1]
      @waiting_http_response = true
    rescue
      # tentar DNS
      @host.send_packet "A #{a[1]}", @host.dns
      @waiting_dns_response = true
      @msg = args
    end
  end

  def tick
    if @waiting_http_response
      @host.buffer.shift if @host.buffer[0]
    elsif @waiting_dns_response
      if @host.buffer[0]
        addr = @host.buffer.shift.data.split[1]
        @host.send_packet @msg, addr
      end
    end
  end
end