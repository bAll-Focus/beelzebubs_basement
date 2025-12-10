extends Node

@export var IP_ADDRESS : String = "localhost"
@export var PORT : int = 42069
var peer : ENetMultiplayerPeer

@export var role_manager: RoleManager
@export var magic_manager: MagicManager
@export var baal_manager: BaalManager
@export var state_manager: NetworkStateMachine
@export var server_mode: bool = false
@export var debug = false
@export var use_vr = false
@export var little_vr_dude:Node3D
var waiting_for_player = true;

func _on_peer_connected(peer_id: int):
	print("Client connected with ID ", peer_id)
	role_manager.set_authorities(peer_id)
	if(multiplayer.is_server()):
		waiting_for_player = false
		role_manager.initialize_roles(true)
	else:
		role_manager.initialize_roles(false)
		var vr_player = role_manager.VR_player if use_vr else null
		magic_manager.set_up_magic_tracking($"../Dynamic Scene/Player_2")
	state_manager._connected()

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 5)
	multiplayer.multiplayer_peer = peer
	server_mode = true

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	server_mode = false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	role_manager.use_vr = use_vr
	if debug:
		_set_node_type();
	if server_mode:
		start_server()
		print("AM SERVER")
		print("Klient: Vem är det som är server?")
		print("Server: Auhyuck, det är ju jag som är server.")
		little_vr_dude.queue_free()
	else:
		await get_tree().create_timer(4.0).timeout
		start_client()
		print("AM CLIENT")

func _set_node_type() -> void:
	for argument in OS.get_cmdline_args():
		if argument.contains("SERVER"):
			server_mode = true
			role_manager.use_vr = false
			return
	role_manager.use_vr = true if use_vr else false
