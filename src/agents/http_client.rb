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
    rescue
      # tentar DNS
      
    end
  end

  def tick

  end
end