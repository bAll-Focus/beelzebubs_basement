class_name ClientNode
extends UDPNode

var udp = PacketPeerUDP.new()
var connected = false

func _initialize(): 
	udp.connect_to_host("127.0.0.1", 4242)
	initialized = true

func _physics_process(_delta):
	if initialized:
		if !connected:
			udp.put_packet("The answer is... 42!".to_utf8_buffer())
		if udp.get_available_packet_count() > 0:
			for i in udp.get_available_packet_count():
				udp.get_packet()
			connected = true
