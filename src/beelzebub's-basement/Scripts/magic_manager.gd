extends Node
class_name MagicManager

var is_active = false
var spell_effects:Array[GPUParticles3D]

func set_up_magic_tracking(magic_tracker_holder) -> void: # Magic tracker holder is simply the VR player node.
	if magic_tracker_holder == null:
		magic_tracker_holder = $"Hittepåmagi"
		magic_tracker_holder.spell_cast.connect(cast_magic)
	else:
		var spell_tracker_1 = magic_tracker_holder.get_node("LeftController").get_child(0)
		var spell_tracker_2 = magic_tracker_holder.get_node("RightController").get_child(0)
		spell_tracker_1.connect(cast_magic)
		spell_tracker_2.connect(cast_magic)

func cast_magic(spell, hand) -> void:
	if(is_active):
		on_magic_cast.rpc(spell, hand)

@rpc("any_peer")
func on_magic_cast(spell, hand):
	if multiplayer.is_server():
		print("SHADOW WIZARD MONEY GANG, WE LOVE CASTING SPELLS (", spell, ":", hand, ")")
		match spell:
			"reveal_demon":
				pass
			"slow_demon":
				pass
			"empower_throw_fire":
				pass
			"empower_throw_ice":
				pass

@rpc
func set_ball_spell(spell_type:int):
	for i in spell_effects.size():
		spell_effects[i].visible = spell_type == i
	#TODO: also set spell damage type in balltracker
