extends Node3D

@export var end_position:Vector3
@export var movedistance:float
@export var move_direction:Vector3
var start_position:Vector3
@export var movement_speed:float
var to_be_shown:bool = false


func _ready():
	position = end_position - movedistance * move_direction
	start_position = position
	to_be_shown = true

func set_visibility(value):
	to_be_shown = value
	
func _process(delta: float) -> void:
	var pos = position
	if(to_be_shown):
		position = pos.move_toward(end_position, delta*movement_speed)
	else:
		position = pos.move_toward(position, delta*movement_speed)
