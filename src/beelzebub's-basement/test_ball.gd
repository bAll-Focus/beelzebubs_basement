extends RigidBody3D

@export var fire:GPUParticles3D
@export var ice:GPUParticles3D
@export var cabbage:GPUParticles3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var attacked = false
var init_position = position
var damageIndex = 0
const DAMAGES = [3, 10, 10]
var damage = DAMAGES[damageIndex]

@export var particle_fx_array: Array[GPUParticles3D]
@export var explosion_effects: Array[PackedScene]
signal collision

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	set_damage_type(0)
	body_entered.connect(on_body_entered)

func set_damage_type(damage_type):
	if(multiplayer.is_server()):
		damageIndex = damage_type
		damage = DAMAGES[damageIndex]
		set_particle_visibility.rpc(damageIndex)
		set_particle_visibility(damageIndex)

@rpc
func set_particle_visibility(damage_type):
	for particle_index in particle_fx_array.size():
		particle_fx_array[particle_index].emitting = particle_index == damage_type

func _physics_process(delta: float) -> void:
	# Check current damage
	if Input.is_action_just_pressed("one"):
		set_damage_type(0)
	if Input.is_action_just_pressed("two"):
		set_damage_type(1)
	if Input.is_action_just_pressed("three"):
		set_damage_type(2)

func _collide():
	if multiplayer.is_server():
		print("Ball: Collided with demon")
		collision_effect.rpc(damageIndex)
		collision_effect(damageIndex)
		collision.emit()
	
func on_body_entered(body):
	if multiplayer.is_server():
		print("Ball: Collided with wall")
		if body.name != "Ba'al":
			collision_effect(damageIndex)
			collision_effect.rpc(damageIndex)
		collision.emit()

@rpc
func collision_effect(damage_index):
	var effect_instance = explosion_effects[damage_index].instantiate()
	get_tree().root.add_child(effect_instance)
	print(multiplayer.get_unique_id(), ": created - ", effect_instance.name)
	effect_instance.position = position
