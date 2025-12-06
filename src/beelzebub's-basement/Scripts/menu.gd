extends Control

@export var healthbar:ProgressBar
#@export var baal:Node3D
@export var credits:CanvasLayer

signal start_clicked
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_start_button_pressed() -> void:
	set_visible(false)
	start_clicked.emit()
	#healthbar.set_visible(true)
	#baal.set_visible(true)

func _on_credits_button_pressed() -> void:
	credits.set_visible(true)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
