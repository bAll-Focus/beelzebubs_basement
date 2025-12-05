extends Node3D
class_name Baal_AI

@export var health:int
@export var camera:Camera3D
const MAX_HEALTH = 100
var loop_counter = 0

var hit_sounds = []
var audio_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	#if $"../Camera3D":
		#$"../Camera3D/ProgressBar".value = MAX_HEALTH
		#$"../Camera3D/ProgressBar".set_visible(false)
	#set_visible(false)
	#if $"../Camera3D":
		#$"../Camera3D/Pause Menu".set_visible(false)
		#$"../Camera3D/Credits Menu".set_visible(false)
	hit_sounds.append(preload("res://audio/baal_hit_0.wav"))
	hit_sounds.append(preload("res://audio/baal_hit_1.wav"))
	hit_sounds.append(preload("res://audio/baal_hit_2.wav"))
	audio_player = get_node("AudioStreamPlayer3D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(multiplayer.is_server()):
		loop_counter += delta
		if(loop_counter >= 90):
			loop_counter = -90
		position.x = sin(loop_counter)*1.8
		position.y = cos(4*loop_counter)/6
		rotation.y = cos(loop_counter)/2
		rotation.x = cos(loop_counter*2)/4
	if(health <= 0 && visible):
		set_visible(false)

	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if(body.name == "Ball" && multiplayer.is_server()):
		var val = randi_range(0, 2) 
		audio_player.stream = hit_sounds[val]
		audio_player.play()
		health -= 10
		if camera:
			camera.value -= 10
		if(health <= 0):
			set_visible(false)
			if camera:
				var pm = camera.get_node("Pause Menu")
				pm.set_visible(true)

func restart() -> void:
	if camera:
		var pm = camera.get_node("Pause Menu")
		pm.set_visible(false)
		var pb = camera.get_node("ProgressBar")
		pb.value = MAX_HEALTH
	health = MAX_HEALTH
	#healthbar._init_health(health)
	#healthbar.set_visible(true)
	set_visible(true)
