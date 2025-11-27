extends Node

@export var is_server = false
@export var debug = true
@export var s_node : UDPNode
@export var c_node : UDPNode
@export var camera_s_node : UDPNode


func _ready():
	if not debug:
		if is_server:
			c_node.queue_free()
			c_node = null
		else:
			s_node.queue_free()
			s_node = null
			camera_s_node.queue_free()
			camera_s_node = null
	if(c_node):
		c_node._initialize()
	if(s_node):
		s_node._initialize()
	if(camera_s_node):
		camera_s_node._initialize()
	
