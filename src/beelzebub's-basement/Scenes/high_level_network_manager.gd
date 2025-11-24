extends Node

const IP_ADDRESS : String = "localhost"
const PORT : int = 42069
var peer : ENetMultiplayerPeer

@export var network_player: PackedScene
var je_suis_server: bool = false

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 1)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _ready() -> void:
	for argument in OS.get_cmdline_args():
		if argument.contains("SERVER"):
			je_suis_server = true
	if je_suis_server:
		start_server()
		print("AM SERVER")
	else:
		await get_tree().create_timer(2.0).timeout
		start_client()
		print("AM CLIENT")
	
