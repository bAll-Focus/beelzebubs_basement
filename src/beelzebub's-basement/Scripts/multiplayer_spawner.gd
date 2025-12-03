extends MultiplayerSpawner

@export var network_player: PackedScene
@export var potato: PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	await get_tree().create_timer(5.0).timeout
	spawn_potato(0, Vector3.ZERO + 5*Vector3.FORWARD, Vector3.ZERO)

func spawn_player (_id:int) -> void:
	if !multiplayer.is_server(): return
	#var player: Node = network_player.instantiate()
	#player.name = str(id)
	#get_node(spawn_path).call_deferred("add_child", player)


func spawn_potato (_id:int, position:Vector3, rotation:Vector3) -> void:
	if !multiplayer.is_server(): return

	var potato_instance:Node3D = potato.instantiate()
	potato_instance.position = position
	potato_instance.rotation = rotation
	
	get_node(spawn_path).add_child(potato_instance)
	
