extends Node3D

var _parent_controller : XRController3D
var _making_sign := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_parent_controller = get_parent() as XRController3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _parent_controller:
		return
		
	var old_sign_made = _making_sign
	_making_sign = _parent_controller.is_button_pressed("thumbs_up")
	if _making_sign and not old_sign_made:
		# New pose detected
		print("Thumbs up detected")
