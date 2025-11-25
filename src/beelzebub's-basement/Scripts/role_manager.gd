extends Node

var connection_active = false;
var is_server = false;

func initialize_roles(server:bool) -> void:
	connection_active = true
	is_server = server
	if server:
		initialize_thrower()
	else:
		initialize_victim()

func initialize_thrower() -> void:
	pass

func initialize_victim() -> void:
	pass
