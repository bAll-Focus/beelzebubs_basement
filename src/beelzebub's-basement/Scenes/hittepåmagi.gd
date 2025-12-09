extends Node

signal spell_cast (spell_name:String, hand:String)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("left_click")):
		spell_cast.emit("reveal_demon", "right")
		pass
	if(Input.is_action_just_pressed("left")):
		spell_cast.emit("empower_throw_fire", "left")
		pass
	if(Input.is_action_just_pressed("right")):
		spell_cast.emit("empower_throw_ice", "left")
		pass
	if(Input.is_action_just_pressed("up")):
		spell_cast.emit("slow_demon", "right")
		pass
