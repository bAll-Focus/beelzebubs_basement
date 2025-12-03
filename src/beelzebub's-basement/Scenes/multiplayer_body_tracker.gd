extends Node3D
class_name BodyTracker

var active = false
var head_target
var hand_l_target
var hand_r_target

@export var server_side = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	await get_tree().create_timer(5.0).timeout
	if(active):
		_synch_body($head, head_target)
		_synch_body($hand_l, hand_l_target)
		_synch_body($hand_r, hand_r_target)
		
func _synch_body(item, target) -> void:
	if target != null:
		item.global_position = target.global_position
		item.global_rotation = target.global_rotation
		
func _set_head(head) -> void:
	head_target = head;
	
func _set_l_hand(hand) -> void:
	hand_l_target = hand
	
func _set_r_hand(hand) -> void:
	hand_r_target = hand
