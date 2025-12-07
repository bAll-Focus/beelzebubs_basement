extends Sprite3D

@export var baal_offset = Vector3(0, 0.045, 0.748)
@export var baal:Baal_AI
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.x = baal.position.x + baal_offset.x
	pass
