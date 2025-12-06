class_name CameraServerNode
extends Node

@export var ball_force = Vector3(0,0,0)
var reset_position = Vector3(0,0,0)

var server = UDPServer.new()
var peers = []

var ball
var timer
var screen_width = 100 #use this to balance throws towards edges
var screen_height = 100

var throw_ready = true
var resetting_ball = false
var throwing_ball = false
var throw_x = 0

var viewport_width
var time_out = false
var time_out_timer
var server_throwing_ball = false

var is_active = false

func _ready():
	server.listen(5005)
	ball = get_node("Ball")
	timer = get_node("Timer")
	time_out_timer = get_node("TimeOutTimer")
	throw_ready = true
	viewport_width = get_viewport().get_visible_rect().size.x
	set_multiplayer_authority(1)
	
@rpc
func throw_ball():
	ball.apply_impulse(ball_force)
	timer.start()
	throw_ready = false
		
func set_force(coords):
	var norm_y = ((screen_height - coords.y)/screen_height) * 0.2
	ball.position.y = 0.5
	ball.position.z = 1.318
	if(throw_ready):
		var norm_x = (coords.x/screen_width) * 5
		ball_force = Vector3(norm_x,3,-8)

@rpc
func throw_ball_mouse():
	reset_ball()
	ball.apply_impulse(ball_force)
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
	if throwing_ball and multiplayer.is_server() && is_active:
		throw_ball_mouse()
		throw_ball_mouse.rpc()
		throwing_ball = false
		
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
				if is_active:
					set_force(force_vector)
					throw_ball()
					throw_ball.rpc()
				


	for i in range(0, peers.size()): 
		pass # Do something with the connected peers.

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT :
			var x =  (event.position.x - (viewport_width/2))/viewport_width
			throw_x = x
			var norm_x = x * 10
			ball_force = Vector3(norm_x,3,-8)
			throwing_ball = true
			resetting_ball = true
			server_throwing_ball = true

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
