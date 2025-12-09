extends RigidBody3D

const SPEED = 5.0
var collided = false
var damageIndex = 0
const DAMAGES = [3, 10, 20]
var damage = DAMAGES[damageIndex]

@onready var renderer = $cabbage
var spawner:MultiplayerSpawner

@export var particle_fx_array: Array[GPUParticles3D]

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	for i in 3:
		particle_fx_array[i] = get_child(i)

func destroy():
	if(multiplayer.is_server()):
		queue_free()

func set_damage_type(damage_type):
	if(multiplayer.is_server()):
		damageIndex = damage_type
		damage = DAMAGES[damageIndex]
		set_particle_visibility(damageIndex)

func set_particle_visibility(damage_type):
	print("Called on ", multiplayer.get_unique_id())
	for particle_index in particle_fx_array.size():
		particle_fx_array[particle_index].emitting = particle_index == damage_type
		print(particle_index, " : ", damage_type)

func body_entered(collidee):
	if collided:
		return
	if collidee.name == "Ba'al":
		print("Ball: Collided with Ba'al")
	else:
		print("Ball: Collided with something")
	collided = true
	renderer.visible = false
	freeze = true
	collision_layer = 0
	collision_mask = 0
	await get_tree().create_timer(1).timeout
	destroy()
	
