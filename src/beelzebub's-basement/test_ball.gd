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


func _physics_process(delta: float) -> void:
	# Check current damage
	if Input.is_action_just_pressed("one"):
		damageIndex = 0
		damage = DAMAGES[damageIndex]
		cabbage.set_visible(true)
		fire.set_visible(false)
		ice.set_visible(false)
	if Input.is_action_just_pressed("two"):
		damageIndex = 1
		damage = DAMAGES[damageIndex]
		ice.set_visible(true)
		fire.set_visible(false)
		cabbage.set_visible(false)
	if Input.is_action_just_pressed("three"):
		damageIndex = 2
		damage = DAMAGES[damageIndex]
		fire.set_visible(true)
		ice.set_visible(false)
		cabbage.set_visible(false)
	

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("left", "right", "forward", "backward")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#var input_vertical := Input.get_axis("down", "up")
	#var vertical := (transform.basis * Vector3(0, input_vertical, 0))
	#
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		#
	#if vertical:
		#velocity.y = vertical.y * SPEED
	#else:
		#velocity.y = move_toward(velocity.y, 0, SPEED)
#
	#move_and_slide()
