extends MultiplayerSpawner


func spawn_potato (item:PackedScene, position:Vector3, rotation:Vector3) -> void:
	if !multiplayer.is_server(): return

	var item_instance:Node3D = item.instantiate()
	item_instance.position = position
	item_instance.rotation = rotation
	
	get_node(spawn_path).add_child(item_instance)
	
