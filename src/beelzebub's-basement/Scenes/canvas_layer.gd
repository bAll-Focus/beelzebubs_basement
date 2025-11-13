extends CanvasLayer
# expects a ColorRect
@onready var color_rect := $ColorRect
func _ready() -> void:
	_fit_to_viewport()
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))

func _on_viewport_size_changed() -> void:
	_fit_to_viewport()

func _fit_to_viewport() -> void:
	if color_rect is Control:
		color_rect.anchor_left = 0.0
		color_rect.anchor_top = 0.0
		color_rect.anchor_right = 1.0
		color_rect.anchor_bottom = 1.0
	else:
		color_rect.rect_size = get_viewport().get_visible_rect().size
