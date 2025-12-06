extends State

@export var baal:Baal_AI
@export var health_bar:ProgressBar
@export var magic_manager:MagicManager

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	if(multiplayer.is_server()):
		baal.set_multiplayer_authority(1)
		baal.ran_out_of_health.connect(_baal_died)
	health_bar.visible = false
	magic_manager.is_active = false

func _ran_out_of_time():
	if multiplayer.is_server():
		state_machine._change_state(4)
		state_machine._change_state.rpc(4)

func _baal_died():
	if multiplayer.is_server():
		state_machine._change_state(5)
		state_machine._change_state.rpc(5)

func client_enter_state():
	health_bar.visible = true
	magic_manager.is_active = true
	pass

func server_enter_state():
	baal.is_active = true
	health_bar.visible = true
	magic_manager.is_active = true
	pass

func server_exit_state():
	health_bar.visible = false
	magic_manager.is_active = false
	pass

func client_exit_state():
	health_bar.visible = false
	magic_manager.is_active = false
	pass

func server_state_update(_delta: float):
	pass
	
func client_state_update(_delta: float):
	pass

func server_state_physics_update(_delta: float):
	pass
	
func client_state_physics_update(_delta: float):
	pass
