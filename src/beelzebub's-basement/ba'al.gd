extends Node3D
class_name Baal_AI

@export var health:int

@export var healthbar:ProgressBar
@export var pause_menu:CanvasLayer
@export var start_menu:CanvasLayer
@export var credits_menu:CanvasLayer
@onready var timerBurn = $TimerBurn
@onready var timerSlow = $TimerSlow

@export var camera:Camera3D
@export var ball:RigidBody3D

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
	#$"../Camera3D/Credits Menu".set_visible(false)
	start_menu.set_visible(true)
	healthbar._init_health(health)
	healthbar.set_visible(false)
	set_visible(false)
	pause_menu.set_visible(false)
	credits_menu.set_visible(false)
	set_multiplayer_authority(1)
	hit_sounds.append(preload("res://audio/baal_hit_0.wav"))
	hit_sounds.append(preload("res://audio/baal_hit_1.wav"))
	hit_sounds.append(preload("res://audio/baal_hit_2.wav"))
	audio_player = get_node("AudioStreamPlayer3D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(multiplayer.is_server()):
		loop_counter += delta*speedEffect
		if(loop_counter >= 90):
			loop_counter = -90
		position.x = sin(loop_counter)*1.8
		position.y = cos(4*loop_counter)/6
		rotation.y = cos(loop_counter)/2
		rotation.x = cos(loop_counter*2)/4
	if(health <= 0 && visible):
		set_visible(false)

@rpc
func update_healthbar(index):
	healthbar._set_health(health)
	if(index != -1):
		healthbar._set_colour(index)

@rpc
func decrease_client_health(amount):
	health -= amount

func decrease_health(amount, index):
	if(multiplayer.is_server()):
		health -= amount
		decrease_client_health.rpc(amount) #guess we're doing it this way 
		update_healthbar(index)
		update_healthbar.rpc(index)
	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.name == "Ball" && multiplayer.is_server():
		#var val = randi_range(0, 2) 
		#audio_player.stream = hit_sounds[val]
		#audio_player.play()
		
		damage = ball.damage
		index = ball.damageIndex
		decrease_health(damage, index)
		
		#if camera:
		#	camera.value -= 10
		if(health <= 0):
			set_visible(false)
			#if camera:
			#	var pm = camera.get_node("Pause Menu")
			#	pm.set_visible(true)
		
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
	decrease_health(3,-1)
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
