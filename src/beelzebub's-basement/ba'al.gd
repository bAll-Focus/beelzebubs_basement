extends Node3D

@export var health:int
const MAX_HEALTH = 100
var loop_counter = 0
var ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	$"../Camera3D/ProgressBar".value = MAX_HEALTH
	$"../Camera3D/ProgressBar".set_visible(false)
	set_visible(false)
	$"../Camera3D/Pause Menu".set_visible(false)
	$"../Camera3D/Credits Menu".set_visible(false)
	ball = $"../../Ball"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	loop_counter += delta
	if(loop_counter >= 90):
		loop_counter = -90
	position.x = sin(loop_counter)
	position.y = cos(4*loop_counter)/6

	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if(body.name == "Ball"):
		health -= 10
		$"../Camera3D/ProgressBar".value -= 10
		if(health <= 0):
			set_visible(false)
			$"../Camera3D/Pause Menu".set_visible(true)

func restart() -> void:
	$"../Camera3D/Pause Menu".set_visible(false)
	$"../Camera3D/ProgressBar".value = MAX_HEALTH
	health = MAX_HEALTH
	set_visible(true)
