extends RigidBody3D

@export var fire:GPUParticles3D
@export var ice:GPUParticles3D
@export var cabbage:GPUParticles3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var attacked = false
var init_position = position
var damageIndex = 0
const DAMAGES = [3, 10, 20]
var damage = DAMAGES[damageIndex]

@export var particle_fx_array: Array[GPUParticles3D]

func _ready() -> void:
	set_damage_type(0)

func set_damage_type(damage_type):
	if(multiplayer.is_server()):
		damageIndex = damage_type
		damage = DAMAGES[damageIndex]
		set_particle_visibility.rpc(damageIndex)
		set_particle_visibility(damageIndex)

@rpc
func set_particle_visibility(damage_type):
	print("Called on ", multiplayer.get_unique_id())
	for particle_index in particle_fx_array.size():
		particle_fx_array[particle_index].emitting = particle_index == damage_type
		print(particle_index, " : ", damage_type)

func _physics_process(delta: float) -> void:
	# Check current damage
	if Input.is_action_just_pressed("one"):
		set_damage_type(0)
	if Input.is_action_just_pressed("two"):
		set_damage_type(1)
	if Input.is_action_just_pressed("three"):
		set_damage_type(2)
		

func _collide():
	set_damage_type(0)
	print("Ball: Collided with demon")
