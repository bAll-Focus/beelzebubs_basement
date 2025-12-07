extends State

@export var pause_menu:CanvasLayer
@export var credits_menu:CanvasLayer
@export var baal_text:TextWriteOutBuffer
@export var baal_win_lines:Array[String]
var server_done = false
var client_done = false

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	pause_menu.visible = false
	credits_menu.visible = false

func client_enter_state():
	await baal_text.write_text_set(baal_win_lines)
	client_is_done.rpc()

@rpc("any_peer")
func client_is_done():
	client_done = true

func server_enter_state():
	server_done = false
	client_done = false
	server_done = true

func _exit_state():
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
