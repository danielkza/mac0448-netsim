require_relative 'simulator'
require_relative 'packet'

sim = Simulator.new

r0 = Router.new(0, '10.0.0.1', 1, '10.0.1.1')
r1 = Router.new(0, '10.0.2.1', 1, '10.0.3.1', 2, '10.0.4.1')

h0 = Host.new('10.0.0.2', '10.0.0.1', '10.0.0.5')
h1 = Host.new('10.0.1.3', '10.0.1.1', '10.0.0.5')
h2 = Host.new('10.0.0.4', '10.0.0.1', '10.0.0.5')
h3 = Host.new('10.0.0.5', '10.0.0.1', '1.1.1.1')

l0 = Link.new h0, r0[0], 1000, 10
l1 = Link.new h1, r0[1], 1000, 10
l2 = Link.new h2, r0[0], 1000, 10
l3 = Link.new h3, r0[0], 1000, 10
l4 = Link.new h3, r1[2], 1000, 10

r0.set_performance(150, 0, 1000, 1, 2000)
# r0.add_route('10.0.0.0', 0, '10.1.0.0', 1, '192.168.0.0', '192.168.3.1')
# r0.send_packet(0, Packet.new(NetworkInterface.new('10.0.0.5', 5), NetworkInterface.new('10.0.0.6', 47)))
# r0.send_packet(0, Packet.new(NetworkInterface.new('10.0.0.5', 5), NetworkInterface.new('10.1.5.6', 47)))

h0.attach_agent(a0 = Agent.new('HTTPServer'))
h1.attach_agent(a1 = Agent.new('FTPServer'))
h2.attach_agent(a2 = Agent.new('HTTPClient'))
h3.attach_agent(a3 = Agent.new('DNSServer'))

l0.attach_sniffer 's0', 's0.txt'
l1.attach_sniffer 's1', 's1.txt'
l2.attach_sniffer 's2', 's2.txt'
l3.attach_sniffer 's3', 's3.txt'

sim.add r0, h0, h1, h2, h3, l0, l1, l2, l3

sim.at(0.1, a2, 'GET blabalbla')
   .at(0.3, a0, 'get address...')
   .at(0.4, a3, 'send address...')
   .at(0.4, a2, 'GET abc123')
   .at(0.5, 'finish')

loop { sim.tick }