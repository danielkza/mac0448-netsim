require_relative 'simulator'
require_relative 'ip/packet'

sim = Simulator.new

r0 = Router.new 4
h0 = Host.new
h0.config '10.0.0.2', '5.5.5.5', '10.0.0.1'
h1 = Host.new
h1.config '10.0.0.3', '5.5.5.5', '10.0.0.1'
l0 = Link.new h0, r0[0], 554, 4
l1 = Link.new h1, r0[1], 45, 234
r0.add_interface(0, '10.0.0.1')
r0.add_interface(1, '10.0.0.1')
r0.set_performance 100, 0, 4345, 1, 2453

h0.send_packet(IP::Packet.new(version: 4, dscp: 0, ecn: 0, id: 0xda00,
                              flags: 0x02, frag_offset: 0, ttl: 64,
                              protocol: IP::Packet::PROTO_UDP,
                              src: IPAddr.new('10.0.0.2').to_i, dst: IPAddr.new('10.0.0.3').to_i, data: "\0" * 1410))
h1.send_packet(IP::Packet.new(version: 4, dscp: 0, ecn: 0, id: 0xda00,
                              flags: 0x02, frag_offset: 0, ttl: 64,
                              protocol: IP::Packet::PROTO_UDP,
                              src: IPAddr.new('10.0.0.3').to_i, dst: IPAddr.new('10.0.0.2').to_i, data: "\0" * 1410))

# h0.attach_agent(a0 = Agent.new('HTTPServer'))
# h1.attach_agent(a1 = Agent.new('FTPServer'))
# h2.attach_agent(a2 = Agent.new('HTTPClient'))
# h3.attach_agent(a3 = Agent.new('DNSServer'))
#
# l0.attach_sniffer 's0', 's0.txt'
# l1.attach_sniffer 's1', 's1.txt'
# l2.attach_sniffer 's2', 's2.txt'
# l3.attach_sniffer 's3', 's3.txt'

sim.add r0, h0, h1, l0, l1

sim.at(0.5, 'finish')

loop { sim.tick }