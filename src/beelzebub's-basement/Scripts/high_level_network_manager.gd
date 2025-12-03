extends Node

@export var IP_ADDRESS : String = "localhost"
@export var PORT : int = 42069
var peer : ENetMultiplayerPeer

@export var role_manager: RoleManager
@export var server_mode: bool = false
@export var debug = false

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 5)
	multiplayer.multiplayer_peer = peer
	server_mode = true
	if role_manager:
		role_manager.initialize_roles(true)
	print(multiplayer.is_server());

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	server_mode = false
	if role_manager:
		role_manager.initialize_roles(false)

func _ready() -> void:
	server_mode = false
	if debug:
		_set_node_type();
	if server_mode:
		start_server()
		print("AM SERVER")
	else:
		await get_tree().create_timer(2.0).timeout
		start_client()
		print("AM CLIENT")

func _set_node_type() -> void:
	for argument in OS.get_cmdline_args():
		if argument.contains("SERVER"):
			server_mode = true
			role_manager.use_vr = false
			return
	role_manager.use_vr = true
