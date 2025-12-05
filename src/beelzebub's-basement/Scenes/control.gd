extends Control

@export var baal:Node3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_button_pressed() -> void:
	baal.restart()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
