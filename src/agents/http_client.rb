require_relative '../agent'

class Agents::HTTPClient < Agent
  def run_action args
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
      @waiting_dns_response = a[1]
      @msg = args
    end
  end

  def tick
    if @waiting_http_response
      if @host.buffer[0]
        pkt = @host.buffer.shift
        puts 'recebi:'
        puts pkt.data
        @waiting_http_response = false
      end
    elsif @waiting_dns_response
      if @host.buffer[0]
        data = @host.buffer.shift.data.split
        if data[0] == @waiting_dns_response
          @host.send_packet @msg, data[2]
          @waiting_http_response = true
          @waiting_dns_response = false
        end
      end
    end
  end
end