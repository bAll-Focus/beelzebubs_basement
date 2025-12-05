extends Node
class_name RoleManager

var connection_active = false;
var is_server = false;
var use_vr = false;
var VR_player = Node3D;
@export var victim_pos_marker = Node3D;
@export var thrower_pos_marker = Node3D;

var throw_player = preload("res://Scenes/player_1.tscn"); #This is the packed scene containing the throw VR player setup
var victim_player = preload("res://Scenes/player_2.tscn"); #This is the packed scene containing the victim VR player setup

@export var victim_body_parts:BodyTracker #Items we do a little synch on
@export var thrower_body_parts:BodyTracker #same as above

func initialize_roles(server:bool) -> void:
	connection_active = true
	is_server = server
	if server:
		initialize_thrower()
	else:
		initialize_victim()

func initialize_thrower() -> void:
	if(use_vr):
		VR_player = throw_player.instantiate()
		$"../../Dynamic Scene".add_child(VR_player)
		VR_player.position = thrower_pos_marker.position
		thrower_body_parts.head_target = VR_player.get_node("XRCamera3D")
		thrower_body_parts.hand_l_target = VR_player.get_node("LeftTrackedHand")
		thrower_body_parts.hand_r_target = VR_player.get_node("RightTrackedHand")
		thrower_body_parts.active = true
	else:
		$"../../Camera3D".position = thrower_pos_marker.position

func initialize_victim() -> void:
	if(use_vr): #if vr, couple hands and head
		VR_player = victim_player.instantiate()
		$"../../Dynamic Scene".add_child(VR_player)
		VR_player.position = victim_pos_marker.position
		victim_body_parts.head_target = VR_player.get_node("XRCamera3D")
		victim_body_parts.hand_l_target = VR_player.get_node("LeftTrackedHand")
		victim_body_parts.hand_r_target = VR_player.get_node("RightTrackedHand")
		victim_body_parts.active = true
	else:
		$"../../Camera3D".position = victim_pos_marker.position

func set_up_victim () -> void:
	pass

func set_up_thrower () -> void:
	pass

func set_authorities(peer_id) -> void:
	if not multiplayer.is_server():
		thrower_body_parts.set_multiplayer_authority(1)
		victim_body_parts.set_multiplayer_authority(multiplayer.get_unique_id())
		return
	thrower_body_parts.set_multiplayer_authority(1)
	victim_body_parts.set_multiplayer_authority(peer_id)
