extends Node3D

func _process(delta):
	rotate(Vector3.UP, delta*1/2);
