extends GPUParticles3D

@export var existence_time:float = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	get_child(0).emitting = true
	await get_tree().create_timer(existence_time+1).timeout
	get_child(0).queue_free()
	queue_free()
