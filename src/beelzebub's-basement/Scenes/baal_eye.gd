extends MeshInstance3D

@export var baal_offset = Vector3(0, 0.045, 0.748)
@export var turn_target: Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if turn_target:
		look_at(turn_target.global_position, Vector3.UP, true)
	else:
		look_at($"../../Camera3D".global_position, Vector3.UP, true)
