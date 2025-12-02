extends MeshInstance3D


func _process(delta):
	rotate(Vector3.UP, 1.0/4.0*delta)
	pass
