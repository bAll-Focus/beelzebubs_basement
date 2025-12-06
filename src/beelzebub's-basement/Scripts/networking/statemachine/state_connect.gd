extends State

func _initialize_state(state_machine_node:NetworkStateMachine, root_node:Node):
	state_machine = state_machine_node
	root = root_node

func client_enter_state():
	pass

func server_enter_state():
	pass

func _exit_state():
	pass

func server_state_update(_delta: float):
	pass
	
func client_state_update(_delta: float):
	pass

func server_state_physics_update(_delta: float):
	pass
	
func client_state_physics_update(_delta: float):
	pass
