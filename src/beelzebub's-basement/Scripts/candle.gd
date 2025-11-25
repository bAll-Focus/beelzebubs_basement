extends Node3D

func _process(delta):
	rotate(Vector3.FORWARD, delta*1/4);
