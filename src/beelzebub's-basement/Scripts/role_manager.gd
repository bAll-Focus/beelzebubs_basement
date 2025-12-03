extends Node
class_name RoleManager

var connection_active = false;
var is_server = false;
@export var VR_player = Node3D;
@export var victim_pos_marker = Node3D;
@export var thrower_pos_marker = Node3D;

var throw_player = preload("res://Scenes/player_1.tscn");
var victim_player = preload("res://Scenes/player_2.tscn");

@export var victim_body_parts:Node3D
@export var thrower_body_parts:Node3D

func initialize_roles(server:bool) -> void:
	connection_active = true
	is_server = server
	if server:
		initialize_thrower()
	else:
		initialize_victim()

func initialize_thrower() -> void:
	VR_player = throw_player.instantiate()
	$"../../Dynamic Scene".add_child(VR_player)
	VR_player.position = thrower_pos_marker.position
	#VR_player.get_node("XRCamera3D").add_child(thrower_body_parts.get_node("head"))
	#VR_player.get_node("RightTrackedHand").add_child(thrower_body_parts.get_node("hand_r"))
	#VR_player.get_node("LeftTrackedHand").add_child(thrower_body_parts.get_node("hand_l"))
	pass

func initialize_victim() -> void:
	VR_player = victim_player.instantiate()
	$"../../Dynamic Scene".add_child(VR_player)
	VR_player.position = victim_pos_marker.position
	#VR_player.get_node("XRCamera3D").add_child(victim_body_parts.get_node("head"))
	#VR_player.get_node("RightTrackedHand").add_child(victim_body_parts.get_node("hand_r"))
	#VR_player.get_node("LeftTrackedHand").add_child(victim_body_parts.get_node("hand_l"))
	pass
