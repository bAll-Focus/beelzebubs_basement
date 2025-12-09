extends Node
class_name TextWriteOutBuffer
signal writeout_finished


@export var TextHolder: Node3D
@export var TextLabel: Label3D
@export var pulsating:bool
@export var voiced:bool
@export var seconds_per_character: float = 0.03
@export var wait_before_continue: float = 0.8

@onready var voicebox: ACVoiceBox = $"../ACVoiceBox"
@export var voice_pitch:float

var _writing := false
var pulse_count = 0

func _ready() -> void:
	pass
	#voicebox.connect("characters_sounded", _write_string)
	#voicebox.connect("finished_phrase", _on_voicebox_finished_phrase)

func _process(delta):
	if(pulsating):
		pulse_count += 0.02
		var rescaling = (sin(pulse_count)*0.0001)
		TextHolder.scale = TextHolder.scale + Vector3(rescaling,rescaling,0)
		#TextHolder.modulate.a = 0.8 + (sin(pulse_count)*0.2)
		
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
	if(voiced):
		voicebox.clear_buffer()
	emit_signal("writeout_finished")
	hide()

func _write_string(text: String) -> void:
	TextLabel.text = ""
	
	if(voiced):
		if(len(text) > 0):
			voicebox.play_string(text)
			voicebox.base_pitch = voice_pitch
	for c in text:
		TextLabel.text += c
		await get_tree().create_timer(seconds_per_character).timeout
