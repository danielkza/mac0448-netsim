require_relative 'simulator'

sim = Simulator.new

r0 = Router.new 3
r1 = Router.new 2
h0 = Host.new
h1 = Host.new
h2 = Host.new

h0.config '10.0.0.2', '192.168.0.2', '10.0.0.1'
h1.config '10.0.0.3', '5.5.5.5', '10.0.0.1'
h2.config '192.168.0.2', '5.5.5.5', '192.168.0.1'

r0.name = 'r0'
r1.name = 'r1'
h0.name = 'h0'
h1.name = 'h1'
h2.name = 'h2'

r0.add_interface(0, '10.0.0.1')
r0.add_interface(1, '10.0.0.1')
r0.add_interface(2, '10.0.0.1')
r0.add_route_ip '192.168.0.0', '192.168.0.1'
r0.set_processing_time 100
r0.set_capacity 0, 4345
r0.set_capacity 1, 2453
r0.set_capacity 2, 2453
r1.add_interface 0, '192.168.0.1'
r1.add_interface 1, '192.168.0.1'
r1.add_route_ip '10.0.0.0', '10.0.0.1'
r1.set_processing_time 34
r1.set_capacity 0, 333
r1.set_capacity 1, 434

l0 = Link.new h0[0], r0[0], 554, 4
l1 = Link.new h1[0], r0[1], 45, 234
l2 = Link.new h2[0], r1[0], 43, 345
l3 = Link.new r0[2], r1[1], 34, 233

h0.attach_agent(Agents::HTTPClient.new)
h1.attach_agent(Agents::HTTPServer.new)
h2.attach_agent(Agents::DNSServer.new)

sim.add r0, r1, h0, h1, h2, l0, l1, l2, l3

r0.prepare
r1.prepare
h0.prepare
h1.prepare
h2.prepare

# h0.send_packet('a' * 1410, '10.0.0.3')
# h1.send_packet('b' * 1410, '10.0.0.2')
# h1.send_packet('c' * 1410, '192.168.0.2')

sim.add_action(100, h0, 'GET h1')
sim.add_simulator_action(1500, 'finish')

loop { sim.tick }
