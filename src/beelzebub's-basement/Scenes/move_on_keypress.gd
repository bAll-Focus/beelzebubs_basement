extends Node3D

func _process(delta: float) -> void:
	if Input.is_action_pressed("forward"):
		print(multiplayer.get_unique_id(), " is trying to move me, who has ", get_multiplayer_authority())
		if is_multiplayer_authority():
			print("Moving!!" , multiplayer.get_unique_id())
			position.y += delta*2
		
