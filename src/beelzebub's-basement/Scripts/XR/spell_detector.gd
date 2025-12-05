extends Node3D

const POSE_ACTIONS : Dictionary = {
	"fist": "grip",
	"point": "point",
	"thumbs_up": "thumbs_up",
	"peace_sign": "peace_sign",
}

const SPELLS := {
	"reveal_demon": {
		"hand": "right",
		"sequence": ["peace_sign", "thumbs_up", "point"],
	},
	"protect_self": {
		"hand": "right",
		"sequence": ["point", "fist", "thumbs_up"],
	},
	"empower_throw_holy": {
		"hand": "left",
		"sequence": ["fist", "point", "peace_sign"],
	},
	"empower_throw_ice": {
		"hand": "left",
		"sequence": ["thumbs_up", "fist", "peace_sign"],
	},
}

signal spell_cast(spell_name: String, hand: String)

var _parent_controller : XRController3D
var _pose_states : Dictionary[String, bool] = {}
var _spell_progress : Dictionary[String, int] = {}
var _hand_name := "unknown"

func _ready() -> void:
	_parent_controller = get_parent() as XRController3D
	if _parent_controller:
		_hand_name = _get_hand_name()
		_init_pose_states()
		_init_spell_progress()
		print("SpellDetector initialized for ", _hand_name, " hand (tracker: ", _parent_controller.tracker, ")")

func _process(_delta: float) -> void:
	if not _parent_controller:
		return

	for pose_name: String in POSE_ACTIONS.keys():
		var action_name: String = POSE_ACTIONS[pose_name]
		var is_active := _parent_controller.is_button_pressed(action_name)
		var was_active: bool = _pose_states.get(action_name, false)
		_pose_states[action_name] = is_active

		if is_active and not was_active:
			_on_pose_detected(pose_name, action_name)
			_check_spells(pose_name)


func _init_pose_states() -> void:
	for action_name in POSE_ACTIONS.values():
		_pose_states[action_name] = false


func _on_pose_detected(pose_name: String, action_name: String) -> void:
	print(
		pose_name.capitalize(),
		" detected on ",
		_hand_name,
		" hand (action: ",
		action_name,
		", tracker: ",
		_parent_controller.tracker,
		")"
	)


func _get_hand_name() -> String:
	if not _parent_controller or not _parent_controller.tracker:
		return "unknown"
	if "/left" in _parent_controller.tracker:
		return "left"
	if "/right" in _parent_controller.tracker:
		return "right"
	return "unknown"


func _init_spell_progress() -> void:
	for spell_name in SPELLS.keys():
		_spell_progress[spell_name] = 0


func _check_spells(pose_name: String) -> void:
	for spell_name in SPELLS.keys():
		var spell_data : Dictionary = SPELLS[spell_name]
		var required_hand : String = spell_data["hand"]
		if required_hand != _hand_name:
			continue

		var sequence : Array = spell_data["sequence"]
		var current_index : int = _spell_progress.get(spell_name, 0)

		if pose_name == sequence[current_index]:
			current_index += 1
			if current_index >= sequence.size():
				_spell_progress[spell_name] = 0
				_on_spell_completed(spell_name, required_hand)
			else:
				_spell_progress[spell_name] = current_index
		else:
			_spell_progress[spell_name] = 1 if pose_name == sequence[0] else 0


func _on_spell_completed(spell_name: String, hand: String) -> void:
	print(spell_name.capitalize(), " spell cast on ", hand, " hand!")
	spell_cast.emit(spell_name, hand)
