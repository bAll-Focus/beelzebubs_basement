extends State

@export var baal:Baal_AI
@export var pause_menu:CanvasLayer
@export var credits_menu:CanvasLayer
@export var baal_text:TextWriteOutBuffer
@export var baal_win_lines_client:Array[String]
@export var baal_win_lines_server:Array[String]
var server_done = false
var client_done = false

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	pause_menu.visible = false
	credits_menu.visible = false

func client_enter_state():
	baal.set_visibility(true)
	await baal_text.write_text_set(baal_win_lines_client)
	client_is_done.rpc()

@rpc("any_peer")
func client_is_done():
	client_done = true

func server_enter_state():
	server_done = false
	client_done = false
	baal.stop_all_timers()
	await baal_text.write_text_set(baal_win_lines_server)
	server_done = true

func server_exit_state():
	baal.set_visibility(false)
	pass

func client_exit_state():
	baal.set_visibility(false)
	pass

func server_state_update(_delta: float):
	if server_done and client_done:
		state_machine._change_state(1)
		state_machine._change_state.rpc(1)
		server_done = false
		client_done = false
	
func client_state_update(_delta: float):
	pass

func server_state_physics_update(_delta: float):
	pass
	
func client_state_physics_update(_delta: float):
	pass
