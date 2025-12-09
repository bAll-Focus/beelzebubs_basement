extends Node
class_name MagicManager

var is_active = false
var spell_effects:Array[GPUParticles3D]

signal revealed_demon
signal ball_power_set
signal slowed_demon

func set_up_magic_tracking(magic_tracker_holder) -> void: # Magic tracker holder is simply the VR player node.
	if magic_tracker_holder == null:
		magic_tracker_holder = $"Hittepåmagi"
		magic_tracker_holder.spell_cast.connect(cast_magic)
	else:
		var spell_tracker_1 = magic_tracker_holder.get_node("LeftController").get_child(0)
		var spell_tracker_2 = magic_tracker_holder.get_node("RightController").get_child(0)
		spell_tracker_1.spell_cast.connect(cast_magic)
		spell_tracker_2.spell_cast.connect(cast_magic)

func cast_magic(spell, hand) -> void:
	if(is_active):
		on_magic_cast.rpc(spell, hand)

@rpc("any_peer")
func on_magic_cast(spell, hand):
	if multiplayer.is_server():
		print("SHADOW WIZARD MONEY GANG, WE LOVE CASTING SPELLS (", spell, ":", hand, ")")
		match spell:
			"reveal_demon":
				reveal_demon()
			"slow_demon": #Do we need this? Why do we have ice then?
				slow_demon()
			"empower_throw_fire":
				set_ball_on_fire()
			"empower_throw_ice":
				set_ball_on_ice()

func reveal_demon():
	revealed_demon.emit()

func slow_demon():
	slowed_demon.emit()

func set_ball_on_fire():
	ball_power_set.emit(1)

func set_ball_on_ice():
	ball_power_set.emit(2)
