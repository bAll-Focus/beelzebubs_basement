extends ProgressBar

@onready var timer = $Timer

var health = 0 : set = _set_health

func _init_health(_health):
		health = _health
		max_value = health
		value = health
		$Damagebar.max_value = health
		$Damagebar.value = health
		
func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		health = 0
		value = health
		
	if health < prev_health:
		timer.start()
	else:
		$Damagebar.value = health

func _on_timer_timeout() -> void:
	$Damagebar.value = health

func _reset():
	health = max_value
	value = health
	$Damagebar.value = health
