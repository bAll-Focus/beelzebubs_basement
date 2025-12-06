extends Node
class_name NetworkStateMachine

@export var current_state: State
@export var states : Array[State]
@export var root: Node
@export var wait_state : State
var initialized = false

func _ready():
	states.resize(get_child_count())
	var actual_size = 0
	for child in get_children():
		if not child is State:
			continue
		states[actual_size] = child
		actual_size += 1
		child._initialize_state(self, root)
	states.resize(actual_size)
	if not current_state:
		current_state = get_child(0)
		if not get_child(0):
			push_error("No children detected")
	initialized = true

func _connected():
	if not initialized:
		_ready()
	if multiplayer.is_server():
		_change_state(1)
		_change_state.rpc(1)
		print("We are in a lobby!")

@rpc
func _change_state(index:int):
	var new_state:State = get_child(index)
	if new_state == current_state:
		push_warning("Attempting to set current state to itself.")
	if current_state is State:
		if  multiplayer.is_server():
			current_state.server_exit_state()
		else:
			current_state.client_exit_state()
	if  multiplayer.is_server():
		new_state.server_enter_state()
	else:
		new_state.client_enter_state()
	print(multiplayer.get_unique_id(), ": ", name , " - " , "Entering new state " , new_state.name)
	current_state = new_state

func _process(delta):
	if not initialized:
		return
	if multiplayer.is_server():
		current_state.server_state_update(delta)
	else: 
		current_state.client_state_update(delta)

func _physics_process(delta):
	if not initialized:
		return
	if multiplayer.is_server():
		current_state.server_state_physics_update(delta)
	else: 
		current_state.client_state_physics_update(delta)
