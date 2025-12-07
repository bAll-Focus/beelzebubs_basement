extends TextureRect
@export var add_movement:bool = true
var move_counter = 0

func _process(delta: float) -> void:
	if(add_movement):
		move_counter += 0.02
		var rotation_angle = sin(move_counter) * 0.2
		rotation = rotation_angle
	pass
