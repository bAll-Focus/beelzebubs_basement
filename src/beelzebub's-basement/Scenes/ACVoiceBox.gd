extends AudioStreamPlayer
class_name ACVoiceBox

signal characters_sounded(characters)
signal finished_phrase()


const PITCH_MULTIPLIER_RANGE := 0.3
const INFLECTION_SHIFT := 0.4

@export var base_pitch := 3.5 # (float, 2.5, 4.5)

const sounds = {
	'a': preload('res://audio/Sounds/a.wav'),
	'b': preload('res://audio/Sounds/b.wav'),
	'c': preload('res://audio/Sounds/c.wav'),
	'd': preload('res://audio/Sounds/d.wav'),
	'e': preload('res://audio/Sounds/e.wav'),
	'f': preload('res://audio/Sounds/f.wav'),
	'g': preload('res://audio/Sounds/g.wav'),
	'h': preload('res://audio/Sounds/h.wav'),
	'i': preload('res://audio/Sounds/i.wav'),
	'j': preload('res://audio/Sounds/j.wav'),
	'k': preload('res://audio/Sounds/k.wav'),
	'l': preload('res://audio/Sounds/l.wav'),
	'm': preload('res://audio/Sounds/m.wav'),
	'n': preload('res://audio/Sounds/n.wav'),
	'o': preload('res://audio/Sounds/o.wav'),
	'p': preload('res://audio/Sounds/p.wav'),
	'q': preload('res://audio/Sounds/q.wav'),
	'r': preload('res://audio/Sounds/r.wav'),
	's': preload('res://audio/Sounds/s.wav'),
	't': preload('res://audio/Sounds/t.wav'),
	'u': preload('res://audio/Sounds/u.wav'),
	'v': preload('res://audio/Sounds/v.wav'),
	'w': preload('res://audio/Sounds/w.wav'),
	'x': preload('res://audio/Sounds/x.wav'),
	'y': preload('res://audio/Sounds/y.wav'),
	'z': preload('res://audio/Sounds/z.wav'),
	'th': preload('res://audio/Sounds/th.wav'),
	'sh': preload('res://audio/Sounds/sh.wav'),
	' ': preload('res://audio/Sounds/blank.wav'),
	'.': preload('res://audio/Sounds/longblank.wav')
}


var remaining_sounds := []


func _ready():
	connect("finished", play_next_sound)


func play_string(in_string: String):
	parse_input_string(in_string)
	play_next_sound()


func play_next_sound():
	if len(remaining_sounds) == 0:
		emit_signal("finished_phrase")
		return
	var next_symbol = remaining_sounds.pop_front()
	emit_signal("characters_sounded", next_symbol.characters)
	# Skip to next sound if no sound exists for text
	if next_symbol.sound == '':
		play_next_sound()
		return
	var sound: AudioStreamWAV = sounds[next_symbol.sound]
	# Add some randomness to pitch plus optional inflection for end word in questions
	pitch_scale = base_pitch + (PITCH_MULTIPLIER_RANGE * randf()) + (INFLECTION_SHIFT if next_symbol.inflective else 0.0)
	stream = sound
	play()


func parse_input_string(in_string: String):
	for word in in_string.split(' '):
		parse_word(word)
		add_symbol(' ', ' ', false)
  

func parse_word(word: String):
	var skip_char := false
	if(len(word) <= 0): return # rej original
	var is_inflective := word[-1] == '?'
	for i in range(len(word)):
		if skip_char:
			skip_char = false
			continue
		# If not the last letter, check if next letter makes a two letter substring, e.g. 'th'
		if i < len(word) - 1:
			var two_character_substring = word.substr(i, i+2)
			if two_character_substring.to_lower() in sounds.keys():
				add_symbol(two_character_substring.to_lower(), two_character_substring, is_inflective)
				skip_char = true
				continue
		# Otherwise check if single character has matching sound, otherwise add a blank character
		if word[i].to_lower() in sounds.keys():
			add_symbol(word[i].to_lower(), word[i], is_inflective)
		else:
			add_symbol('', word[i], false)

# rej original
func clear_buffer():
	remaining_sounds = []

func add_symbol(sound: String, characters: String, inflective: bool):
	remaining_sounds.append({
		'sound': sound,
		'characters': characters,
		'inflective': inflective
	})
