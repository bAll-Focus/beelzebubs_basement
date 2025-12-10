extends Node3D
class_name Baal_AI

@export var health:int

@export var healthbar:ProgressBar
@export var pause_menu:CanvasLayer
@export var start_menu:CanvasLayer
@export var credits_menu:CanvasLayer

@onready var timerBurn:Timer = $TimerBurn
@onready var timerSlow:Timer = $TimerSlow
@onready var timerReveal:Timer = $TimerVisible
@onready var timerStun:Timer = $TimerStun

@onready var particle_parent = $particles
## Particles related to fire. 
#Burning is active the entire duration of fire
#Flare emits a burst of fire when Baal takes fire damage
@export var burning_particle:GPUParticles3D
@export var flare_particle:GPUParticles3D

@export var camera:Camera3D
@export var ball:RigidBody3D
@export var is_active = false

@export var max_health = 100
const BURN_DEFAULT = 5
const BURN_MIN = 2
const BURN_MAX = 6
var loop_counter = 0
var damage
var index
var speedEffect = 1
var burnCount

var stunned = false
var stun = 0

var hit_sounds = []
var audio_player

var start_position:Vector3
var start_rotation:Vector3

signal ran_out_of_health

var is_slowed = false
var is_thawing = false
var thawing_rate = 0.005
var thawing_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	start_rotation = rotation
	timerReveal.timeout.connect(on_reveal_ended)
	timerSlow.timeout.connect(on_slow_ended)
	timerBurn.timeout.connect(_on_timer_timeout)
	timerStun.timeout.connect(_on_timer_stun_timeout)
	_initialize_baal()
	
func _prepare_baal_for_new_round() -> void:
	is_active = false
	_initialize_baal()
	if multiplayer.is_server():
		position = start_position
		rotation = start_rotation

func _initialize_baal() -> void:
	health = max_health
	#$"../Camera3D/Credits Menu".set_visible(false)
	#start_menu.set_visible(true)
	healthbar._init_health(health)
	set_visibility(false)
	set_multiplayer_authority(1)
	hit_sounds = []
	hit_sounds.append(preload("res://audio/baal_hit_0.wav"))
	hit_sounds.append(preload("res://audio/baal_hit_1.wav"))
	hit_sounds.append(preload("res://audio/baal_hit_2.wav"))
	audio_player = get_node("AudioStreamPlayer3D")
	speedEffect = 1
	burning_particle.emitting = false
	flare_particle.emitting = false

func set_visibility(value: bool):
	$CharacterBody3D.visible = value
	$MeshInstance3D.visible = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(multiplayer.is_server()&&is_active):
		if(is_slowed):
			if(stunned):
				stun -= 0.1
			else:
				loop_counter += delta*speedEffect/2
				position.x = sin(loop_counter)*1.8
		elif(is_thawing): 
			if(stunned):
				stun -= 0.15
			else:
				loop_counter += delta*speedEffect/2 + (delta*speedEffect/2)*thawing_counter
				position.x = sin(loop_counter)*1.8
				thawing_counter += thawing_rate
			if(thawing_counter >= 1):
				is_thawing = false
				thawing_counter = 0
		
		else:
			if(stunned):
				stun -= 0.2
			else:
				loop_counter += delta*speedEffect
				position.x = sin(loop_counter)*1.8
		
		position.y = cos(4*loop_counter)/6 + start_position.y/2
		rotation.y = cos(loop_counter)/2 + start_position.y/2 + stun
		rotation.x = cos(loop_counter*2)/4
		if(health <= 0 && is_active):
			ran_out_of_health.emit()
			baal_died.rpc()
			is_active = false
	elif(multiplayer.is_server()):
		position.x = start_position.x
		rotation.y = start_rotation.y
		position.y = sin(Time.get_ticks_msec()/500.0)/10 + start_position.y
		rotation.x = sin(Time.get_ticks_msec()/1000.0)/10 

@rpc
func reveal_spell():
	if multiplayer.is_server():
		reveal_spell.rpc() #call the client version to do something
		timerReveal.start()
		for n in 3:
			set_visibility(false);
			await get_tree().create_timer(0.1).timeout
			set_visibility(true);
			await get_tree().create_timer(0.1).timeout
	else:
		pass
@rpc
func on_reveal_ended():
	if multiplayer.is_server(): 
		on_reveal_ended.rpc() #call the client version to do something
		for n in 3:
			set_visibility(true);
			await get_tree().create_timer(0.1).timeout
			set_visibility(false);
			await get_tree().create_timer(0.1).timeout
	else:
		pass

const SLOW_SPEED_STEPS = 20
const SLOW_SPEED_STEP_TIMER = 0.01

@rpc
func slow_spell():
	if multiplayer.is_server():
		is_slowed = true
		slow_spell.rpc() #call the client version to do something
		#for n in SLOW_SPEED_STEPS:
			#await get_tree().create_timer(SLOW_SPEED_STEP_TIMER).timeout
			#speedEffect -= 0.5/SLOW_SPEED_STEPS
		timerSlow.start()
	else:
		pass
@rpc
func on_slow_ended():
	if multiplayer.is_server():
		is_slowed = false
		is_thawing = true
		on_slow_ended.rpc() #call the client version to do something
		#for n in SLOW_SPEED_STEPS:
			#await get_tree().create_timer(SLOW_SPEED_STEP_TIMER).timeout
			#speedEffect += 0.5/SLOW_SPEED_STEPS
	else:
		pass

@rpc func set_on_fire():
	if multiplayer.is_server():
		set_on_fire.rpc()
		timerBurn.start()
		burnCount = randi_range(BURN_MIN, BURN_MAX) 
		burning_particle.emitting = true
		# Stop cooling of ba'al, but also ensure thawing
		timerSlow.stop()
		on_slow_ended()
	else:
		burning_particle.emitting = true

@rpc func put_out_fire():
	if multiplayer.is_server():
		put_out_fire.rpc()
		timerBurn.stop()
		burning_particle.emitting = false
	else:
		burning_particle.emitting = false

@rpc
func baal_died():
	set_visibility(false);
	health = 0
	is_active = false

#There are a few inconsistensies here that I would like to address, given the time
#However, the script works, so this is a certified "If I have time"-moment
@rpc
func update_healthbar(index):
	healthbar._set_health(health)
	if(index != -1):
		healthbar._set_colour(index)

@rpc
func decrease_client_health(amount):
	health -= amount

func decrease_health(amount, index):
	if(multiplayer.is_server()&&is_active):
		health -= amount
		decrease_client_health.rpc(amount) #guess we're doing it this way 
		update_healthbar(index)
		update_healthbar.rpc(index)
	
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.name == "Ball" && multiplayer.is_server():
		
		stunned = true
		timerStun.start()
		
		var val = randi_range(0, 2) 
		audio_player.stream = hit_sounds[val]
		audio_player.play()
		
		damage = ball.damage
		index = ball.damageIndex
		decrease_health(damage, index)
		
		if index == 1:
			slow_spell()
		
		if index == 2:
			set_on_fire()
		body._collide()

func restart() -> void:
	health = max_health
	set_visibility(true);

# burn timer
func _on_timer_timeout() -> void:
	decrease_health(randi_range(1, 3), 2)
	
	if burnCount > 1:
		burnCount -= 1
		timerBurn.start()
		flare_particle.emitting = true
	if burnCount <= 1:
		put_out_fire()

func _on_timer_stun_timeout() -> void:
	stunned = false
	stun = 0
