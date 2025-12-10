extends Sprite3D

@export var baal_offset = Vector3(0, 0.045, 0.748)
@export var baal:Baal_AI
@export var turn_target: Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.x = baal.position.x + baal_offset.x
	rotate(Vector3.UP, _delta*3)
	if turn_target:
		var fwd = -turn_target.global_basis.z*1000
		look_at(turn_target.global_position + fwd)
	else:
		var fwd = -$"../../Camera3D".global_basis.z*1000
		look_at($"../../Camera3D".global_position + fwd)
	pass
