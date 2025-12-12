extends GPUParticles3D
	
func set_visibility(value):
	print("Particleing: ", value)
	emitting = value

func reset_properties():
	emitting = false
