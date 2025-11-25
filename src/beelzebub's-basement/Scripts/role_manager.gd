extends Node
class_name RoleManager

var connection_active = false;
var is_server = false;
@export var VR_player = Node3D;
@export var victim_pos_marker = Node3D;
@export var thrower_pos_marker = Node3D;

func initialize_roles(server:bool) -> void:
	connection_active = true
	is_server = server
	if server:
		initialize_thrower()
	else:
		initialize_victim()

func initialize_thrower() -> void:
	VR_player.position = thrower_pos_marker.position
	pass

func initialize_victim() -> void:
	VR_player.position = victim_pos_marker.position
	pass
