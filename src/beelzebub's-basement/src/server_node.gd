class_name CameraServerNode
extends Node

var server = UDPServer.new()
var peers = []

var ball

func _ready():
	server.listen(5005)
	ball = get_node("Ball")

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

func _physics_process(delta):
	if(peers.size() > 0):
		for i in range(0, peers.size()):
			var is_available = peers[i].get_available_packet_count()
			if is_available:
				var packet = peers[i].get_packet().get_string_from_utf8()
				#print(packet)
				var coords = packet.split(" ")
				for coord in coords:	
					var data = coord.split(":")
					var force_vector = Vector3(0,0,-10)
					match data[0]:
						"x": force_vector.x = int(data[1])/2
						"y": force_vector.y = int(data[1])/2
						"z": pass
					print(force_vector)
					ball.apply_impulse(force_vector)
				

	for i in range(0, peers.size()): 
		pass # Do something with the connected peers.


func _on_timer_timeout():
	ball.position.x = 0
	ball.position.y = -0.25
	ball.position.z = -2.0
	ball.linear_velocity = Vector3.ZERO 
	ball.angular_velocity = Vector3.ZERO  
	pass # Replace with function body.
