extends CharacterBody3D

@onready var camera_mount = $Camera_Mount
@onready var animation_player = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals = $Visuals

var SPEED = 3
const JUMP_VELOCITY = 4.5
@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15

var running_speed = 6.0
var walking_speed = 3.0
var running = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity_h))
		visuals.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity_h))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity_v))

func _physics_process(delta):
	if Input.is_action_pressed('run'):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if running:
			if animation_player.current_animation != 'running':
				animation_player.play('running')
		else:
			if animation_player.current_animation != 'walking':
				animation_player.play('walking')
		visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != 'idle':
			animation_player.play('idle')
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
