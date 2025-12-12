extends Node3D
class_name Hellflesh

@export var end_position:Vector3
@export var movedistance:float
@export var move_direction:Vector3
var start_position:Vector3
@export var movement_speed:float
var to_be_shown:bool = false


func _ready():
	end_position = position
	position = end_position - movedistance * move_direction
	start_position = position

func set_visibility(value):
	to_be_shown = value
	
func reset_properties():
	position = start_position
	set_visibility(false)
	
func _process(delta: float) -> void:
	var pos = position
	if(to_be_shown):
		position = pos.move_toward(end_position, delta*movement_speed)
	else:
		position = pos.move_toward(position, delta*movement_speed)
