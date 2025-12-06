extends State

@export var start_menu:Control

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node
	start_menu.visible = false
	start_menu.start_clicked.connect(on_start_game)

func client_enter_state():
	start_menu.visible = false

func server_enter_state():
	start_menu.visible = true

func _exit_state():
	start_menu.visible = false

func server_state_update(_delta: float):
	pass
	
func client_state_update(_delta: float):
	pass

func on_start_game():
	if multiplayer.is_server():
		state_machine._change_state(2)
		state_machine._change_state.rpc(2)


func server_state_physics_update(_delta: float):
	pass
	
func client_state_physics_update(_delta: float):
	pass
