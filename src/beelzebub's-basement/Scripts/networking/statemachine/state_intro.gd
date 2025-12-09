extends State

@export var Baal:Node3D
@export var baal_text:TextWriteOutBuffer
@export var thrower_text:TextWriteOutBuffer

@export var baal_intro_lines: Array[String]
@export var thrower_intro_lines: Array[String]

var server_done = false
var client_done = false

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	baal_text.hide()
	thrower_text.hide()

func client_enter_state():
	Baal.set_visibility(true)
	await get_tree().create_timer(0.1).timeout
	Baal.set_visibility(false)
	await get_tree().create_timer(0.3).timeout
	Baal.set_visibility(true)
	await get_tree().create_timer(0.2).timeout
	Baal.set_visibility(false)
	await get_tree().create_timer(0.2).timeout
	Baal.set_visibility(true)
	await get_tree().create_timer(0.2).timeout
	Baal.set_visibility(false)
	await get_tree().create_timer(0.2).timeout
	Baal.set_visibility(true)
	await baal_text.write_text_set(baal_intro_lines)
	finished_baal_intro.rpc()

@rpc("any_peer")
func finished_baal_intro ():
	client_done = true

func server_enter_state():
	Baal._prepare_baal_for_new_round()
	await thrower_text.write_text_set(thrower_intro_lines)
	server_done = true

func _exit_state():
	pass

func server_state_update(_delta: float):
	if multiplayer.is_server() && server_done && client_done:
		state_machine._change_state(3)
		state_machine._change_state.rpc(3)
		server_done = false
		client_done = false
	
func client_state_update(_delta: float):
	pass

func server_state_physics_update(_delta: float):
	pass
	
func client_state_physics_update(_delta: float):
	pass
