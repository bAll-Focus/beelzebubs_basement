extends RigidBody3D

var active : bool = true

func _process(delta: float) -> void:
	if multiplayer.is_server():
		linear_velocity += 2*delta*Vector3.UP
	elif active:
		active = false
		print("Not active")
