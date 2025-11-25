extends Node

const IP_ADDRESS : String = "localhost"
const PORT : int = 42069
var peer : ENetMultiplayerPeer

@export var network_player: PackedScene
var server_mode: bool = false

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 1)
	multiplayer.multiplayer_peer = peer
	server_mode = false

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	server_mode = false

func _ready() -> void:
	server_mode = false
	for argument in OS.get_cmdline_args():
		if argument.contains("SERVER"):
			server_mode = true
	if server_mode:
		start_server()
		print("AM SERVER")
	else:
		await get_tree().create_timer(2.0).timeout
		start_client()
		print("AM CLIENT")
	
