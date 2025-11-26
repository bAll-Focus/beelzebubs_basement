extends Node3D

@export var health:int
const MAX_HEALTH = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	$"../Camera3D/ProgressBar".value = MAX_HEALTH
	$"../Camera3D/ProgressBar".set_visible(false)
	$"../TestBall".set_visible(false)
	set_visible(false)
	$"../Camera3D/Pause Menu".set_visible(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_detection_area_body_entered(body: Node3D) -> void:
	if(body.name == "TestBall"):
		health -= 10
		$"../Camera3D/ProgressBar".value -= 10
		print(health)
		if(health <= 0):
			set_visible(false)
			$"../Camera3D/Pause Menu".set_visible(true)
		$"../TestBall".set_visible(false)
		$"../TestBall".velocity = Vector3(0, 0, 0)
		$"../TestBall".position = Vector3(0, 0.452, 1.247)
		$"../TestBall".set_visible(true)

func restart() -> void:
	$"../Camera3D/Pause Menu".set_visible(false)
	$"../Camera3D/ProgressBar".value = MAX_HEALTH
	health = MAX_HEALTH
	set_visible(true)
	print("RESTART")
