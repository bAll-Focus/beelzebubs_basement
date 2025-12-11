extends State

@export var allfather_node:HighLevelNetworkManager
@export var baal:Baal_AI
@export var pause_menu:CanvasLayer
@export var credits_menu:CanvasLayer
@export var baal_text:TextWriteOutBuffer
@export var baal_loss_lines_client:Array[String]
@export var baal_loss_lines_server:Array[String]
@export var victim_marker:Node3D
@export var hell_marker:Node3D
var server_done = false
var client_done = false

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	pause_menu.visible = false
	credits_menu.visible = false

func client_enter_state():
	baal.set_visibility(true)
	await baal_text.write_text_set(baal_loss_lines_client)
	await get_tree().create_timer(2).timeout
	client_to_hell()
	await get_tree().create_timer(10).timeout
	client_is_done.rpc()

func server_enter_state():
	server_done = false
	client_done = false
	baal.stop_all_timers()
	baal.set_visibility(true)
	await baal_text.write_text_set(baal_loss_lines_server)
	await get_tree().create_timer(2).timeout
	server_done = true

@rpc("any_peer")
func client_is_done():
	client_done = true

func server_exit_state():
	baal.set_visibility(false)
	pass
	

func client_exit_state():
	baal.set_visibility(false)
	reset_client_from_hell()
	pass

@rpc
func client_to_hell():
	if multiplayer.is_server():
		return
	if allfather_node.little_vr_dude == null:
		$"../../../../Camera3D".position = hell_marker.position
		$"../../../../Camera3D".position += Vector3(0, 1.3, 0)
	else:
		allfather_node.little_vr_dude.position = hell_marker.position

@rpc func reset_client_from_hell():
	if multiplayer.is_server():
		return
	if allfather_node.little_vr_dude == null:
		$"../../../../Camera3D".position = victim_marker.position
		$"../../../../Camera3D".position += Vector3(0, 1.3, 0)
	else:
		allfather_node.little_vr_dude.position = victim_marker.position

func server_state_update(_delta: float):
	if server_done && client_done:
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
