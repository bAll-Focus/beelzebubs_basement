extends Node
class_name BaalManager

@export var baal:Node3D
# Called when the node enters the scene tree for the first time.
func start_multiplayer() -> void:
	if(multiplayer.is_server()):
		baal.set_multiplayer_authority(1)
