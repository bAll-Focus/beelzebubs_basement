class_name ServerNode
extends UDPNode

var server = UDPServer.new()
var peers = []
@export var update_tick_hz = 60.0
var update_time

func _initialize():
	update_time = 1.0/update_tick_hz
	server.listen(4242)
	initialized = true

func _process(_delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer = server.take_connection()
		var packet = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet(packet)
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)
		
func _physics_process(_delta):
	if peers.size() > 0:
		for i in range(0, peers.size()):
			peers[i].put_packet((str(_delta)).to_utf8_buffer())
			pass

func _send_object_update():
	pass

func _send_win():
	pass
