class_name CameraServerNode
extends Node

var server = UDPServer.new()
var peers = []

var ball
var timer
var screen_width = 100 #use this to balance throws towards edges
var screen_height = 100

var throw_ready
var throwing_ball = false
var throw_x = 0

var viewport_width

func _ready():
	server.listen(5005)
	ball = get_node("Ball")
	timer = get_node("Timer")
	throw_ready = true
	viewport_width = get_viewport().get_visible_rect().size.x
	
func throw_ball(coords):
	var norm_y = ((screen_height - coords.y)/screen_height) * 0.2
	ball.position.y = 0.5
	ball.position.z = 1.318
	if(throw_ready):
		var norm_x = (coords.x/screen_width) * 5
		ball.apply_impulse(Vector3(norm_x,2,-8))
		timer.start()
		throw_ready = false
		
func throw_ball_mouse(x):
	#print("before: ", ball.position.z)
	#reset_ball()
	#print("after: ", ball.position.z)
	
	
	if(throw_ready):
		var norm_x = x * 10
		ball.apply_impulse(Vector3(norm_x,2,-8))
		#timer.start()
		throw_ready = false
	

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
	if throwing_ball:
		throwing_ball = false
		reset_ball()
		throw_ball_mouse(throw_x)
	if(peers.size() > 0):
		for i in range(0, peers.size()):
			var is_available = peers[i].get_available_packet_count()
			if is_available:
				var packet = peers[i].get_packet().get_string_from_utf8()
				#print(packet)
				var coords = packet.split(" ")
				var force_vector = Vector3(0,0,-10)
				for coord in coords:	
					var data = coord.split(":")
					match data[0]:
						"x": force_vector.x = int(data[1])/2
						"y": force_vector.y = int(data[1])/2
						"z": pass
				print(force_vector)
				throw_ball(force_vector)
				


	for i in range(0, peers.size()): 
		pass # Do something with the connected peers.

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT :
			var x =  (event.position.x - (viewport_width/2))/viewport_width
			throwing_ball = true
			throw_x = x

func reset_ball():
	ball.position.x = 0
	ball.position.y = 0.5
	ball.position.z = 1.318
	ball.linear_velocity = Vector3.ZERO 
	ball.angular_velocity = Vector3.ZERO  
	ball.rotation = Vector3(0,0,0)
	throw_ready = true
	

func _on_timer_timeout():
	reset_ball()
