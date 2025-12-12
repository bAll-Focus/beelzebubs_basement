extends State

@export var baal:Baal_AI
@export var health_bar:ProgressBar
@export var magic_manager:MagicManager
@export var baal_hurt_lines:Array[String]
@export var baal_combat_lines:Array[String]
@export var game_timer:Timer
@export var throw_manager = Node
@export var eyes:Array[Node3D]
@export var tentacles:Array[Node3D]
@export var particles:Array[Node3D]
@export var fight_music:FightMusic

@export var tentacle_timer:Timer
@export var eye_timer:Timer
@export var particle_timer:Timer
@export var surr_surr:AudioStreamPlayer3D

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	if(multiplayer.is_server()):
		baal.set_multiplayer_authority(1)
		baal.ran_out_of_health.connect(_baal_died)
	health_bar.visible = false
	magic_manager.is_active = false
	game_timer.timeout.connect(_ran_out_of_time)
	throw_manager.is_active = false
	
	baal.visible = true
	baal.set_visibility(false)
	
	##Connect neccessary signals here
	magic_manager.revealed_demon.connect(baal.reveal_spell)
	magic_manager.slowed_demon.connect(baal.slow_spell)
	magic_manager.ball_power_set.connect(throw_manager.on_set_damage_type)
	eye_timer.timeout.connect(start_eyes)
	tentacle_timer.timeout.connect(start_tentacles)
	
@rpc
func start_eyes():
	if multiplayer.is_server():
		start_eyes.rpc()
	for eye in eyes:
		eye.set_visibility(true)
@rpc
func start_tentacles():
	if multiplayer.is_server():
		start_tentacles.rpc()
	for tentacle in tentacles:
		tentacle.set_visibility(true)
@rpc
func start_particles():
	if multiplayer.is_server():
		start_particles.rpc()
	for particle in particles:
		particle.set_visibility(true)

func _ran_out_of_time():
	if multiplayer.is_server():
		print("Ran out of time")
		state_machine._change_state(4)
		state_machine._change_state.rpc(4)
		game_timer.stop()

func _baal_died():
	if multiplayer.is_server():
		state_machine._change_state(5)
		state_machine._change_state.rpc(5)
		fight_music._fade_out();

func client_enter_state():
	health_bar.visible = true
	magic_manager.is_active = true
	throw_manager.is_active = true
	baal.set_visibility(true)
	surr_surr.play()
	pass

func server_enter_state():
	baal.is_active = true
	health_bar.visible = true
	magic_manager.is_active = true
	throw_manager.is_active = true
	baal.set_visibility(false)
	game_timer.start()
	fight_music._start_music()
	tentacle_timer.start()
	eye_timer.start()
	particle_timer.start()
	surr_surr.play()
	pass

func start_mutual_timers():
	pass

func server_exit_state():
	RednessStatus.redness = 0
	health_bar.visible = false
	magic_manager.is_active = false
	baal.is_active = false
	throw_manager.is_active = false
	game_timer.stop()
	baal.stop_all_timers()
	surr_surr.stop()
	pass



func client_exit_state():
	RednessStatus.redness = 0
	health_bar.visible = false
	magic_manager.is_active = false
	baal.is_active = false
	baal.stop_all_timers()
	surr_surr.stop()
	pass

func server_state_update(_delta: float):
	RednessStatus.redness += _delta * 0.2/120
	pass
	
func client_state_update(_delta: float):
	RednessStatus.redness += _delta * 0.2/120
	pass

func server_state_physics_update(_delta: float):
	pass
	
func client_state_physics_update(_delta: float):
	pass
