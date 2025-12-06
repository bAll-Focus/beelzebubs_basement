extends Node
class_name TextWriteOutBuffer
signal writeout_finished


@export var TextHolder: Node3D
@export var TextLabel: Label3D
@export var seconds_per_character: float = 0.03
@export var wait_before_continue: float = 0.6

var _writing := false

func hide():
	TextLabel.visible = false
	TextHolder.visible = false

func show():
	TextLabel.visible = true
	TextHolder.visible = true

func write_text_set(strings: Array):
	TextLabel.text = ""  
	show()

	_writing = true
	for s in strings:
		TextLabel.text = ""
		await _write_string(s)
		await get_tree().create_timer(wait_before_continue).timeout

	_writing = false
	emit_signal("writeout_finished")
	hide()

func _write_string(text: String) -> void:
	TextLabel.text = ""
	for c in text:
		TextLabel.text += c
		await get_tree().create_timer(seconds_per_character).timeout
