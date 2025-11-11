extends Node

const SERVER_PORT: int = 8080
const GAME_SCENE = "res://scenes/main.tscn"

func create_server():
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_server(SERVER_PORT)
	get_tree().get_multiplayer().multiplayer_peer = enet_network_peer
	print("Server Created!")

func create_client(host_ip: String = "localhost", host_port: int = SERVER_PORT):
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_client(host_ip, host_port)
	get_tree().get_multiplayer().multiplayer_peer = enet_network_peer
	print("Client peer created!")
	
func _setup_client_connection_signals():
	if not get_tree().get_multiplayer().server_disconnected.is_connected(_server_disconnected):
		get_tree().get_multiplayer().server_disconnected.connect(_server_disconnected)
	
func _server_disconnected():
	print("Server disconnected")
	get_tree().get_multiplayer().multiplayer_peer = null

func load_game_scene():
	print("Loading game scene")
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
