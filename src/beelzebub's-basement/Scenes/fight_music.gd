extends AudioStreamPlayer3D
class_name FightMusic

var target_vol:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_vol = volume_db

func _start_music():
	volume_db = target_vol
	play()

func _fade_out():
	for n in 100:
		volume_db -= 0.5
		await get_tree().create_timer(0.05).timeout
	stop()
	
