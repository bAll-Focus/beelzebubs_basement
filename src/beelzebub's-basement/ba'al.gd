extends Node3D

@export var health:int

@onready var healthbar = $"../Camera3D/Healthbar"
@onready var pause_menu = $"../Camera3D/Pause Menu"
@onready var credits_menu = $"../Camera3D/Credits Menu"
@onready var timerBurn = $Timer
@onready var timerSlow = $Timer2

const MAX_HEALTH = 100
const BURN_DEFAULT = 5
var loop_counter = 0
var damage
var index
var speedEffect = 1
var burnCount

var hit_sounds = []
var audio_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	healthbar._init_health(health)
	healthbar.set_visible(false)
	set_visible(false)
	pause_menu.set_visible(false)
	credits_menu.set_visible(false)
	#hit_sounds.append(preload("res://audio/baal_hit_0.wav"))
	#hit_sounds.append(preload("res://audio/baal_hit_1.wav"))
	#hit_sounds.append(preload("res://audio/baal_hit_2.wav"))
	#audio_player = get_node("AudioStreamPlayer3D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	loop_counter += delta*speedEffect
	
	if(loop_counter >= 90):
		loop_counter = -90
	
	position.x = sin(loop_counter)*1.8
	position.y = cos(4*loop_counter)/6
	rotation.y = cos(loop_counter)/2
	rotation.x = cos(loop_counter*2)/4

	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if(body.name == "TestBall"):
		#var val = randi_range(0, 2) 
		#audio_player.stream = hit_sounds[val]
		#audio_player.play()
		damage = $"../TestBall".damage
		index = $"../TestBall".damageIndex
		
		health -= damage
		healthbar._set_health(health)
		healthbar._set_colour(index)
		
		if index == 1:
			speedEffect = 0.5
			timerSlow.start()
			timerBurn.stop()
		
		if index == 2:
			speedEffect = 1
			burnCount = BURN_DEFAULT
			timerBurn.start()
		
		if(health <= 0):
			set_visible(false)
			pause_menu.set_visible(true)

func restart() -> void:
	pause_menu.set_visible(false)
	health = MAX_HEALTH
	healthbar._init_health(health)
	healthbar.set_visible(true)
	set_visible(true)
	speedEffect = 1

func _on_timer_timeout() -> void:
	health -= 3
	healthbar._set_health(health)
	
	if(health <= 0):
			set_visible(false)
			pause_menu.set_visible(true)
	
	if burnCount > 1:
		burnCount -= 1
		print(burnCount)
		timerBurn.start()


func _on_timer_2_timeout() -> void:
	speedEffect = 1
