class_name ServerNode
extends Node

var server = UDPServer.new()
var peers = []

var ball

func _ready():
	server.listen(5005)
	ball = get_node("MeshInstance3D")

func _process(delta):
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
	if(peers.size() > 0):
		for i in range(0, peers.size()):
			var is_available = peers[i].get_available_packet_count()
			if is_available:
				var packet = peers[i].get_packet().get_string_from_utf8()
				#print(packet)
				var coords = packet.split(" ")
				for coord in coords:	
					var data = coord.split(":")
					match data[0]:
						"x": ball.position.x = int(data[1])/100
						"y": ball.position.y = int(data[1])/100
						"z": pass
				

	for i in range(0, peers.size()):
		pass # Do something with the connected peers.
