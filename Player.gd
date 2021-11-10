extends KinematicBody

onready var camRoot = $CameraRoot
onready var camera = $CameraRoot/Camera

var velocity = Vector3.ZERO
var current_velocity = Vector3.ZERO
var direction = Vector3.ZERO

const MOUSE_SENSITIVITY = 0.1
const SPEED = 10
const SPRINT_SPEED = 20
const ACCEL = 15.0

const GRAVITY = -40.0
const JUMP_SPEED = 15
const AIR_ACCEL = 9.0

var jump_counter = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		camRoot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		camRoot.rotation_degrees.x = clamp(camRoot.rotation_degrees.x, -75, 75)
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

func _process(delta):
	window_activity()

func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	direction = Vector3.ZERO
	
	if Input.is_action_pressed("fwd"):
		direction -= camera.global_transform.basis.z
	if Input.is_action_pressed("back"):
		direction += camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		direction += camera.global_transform.basis.x
	
	direction = direction.normalized()
	
	#jump
	velocity.y += GRAVITY * delta
	if is_on_floor():
		jump_counter = 0
		
	if Input.is_action_just_pressed("jump") and jump_counter < 3:
		jump_counter += 1
		velocity.y = JUMP_SPEED
	
	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var target_vel = direction * speed
	
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	
	current_velocity = \
		current_velocity.linear_interpolate(target_vel, accel * delta)
	velocity.x = current_velocity.x
	velocity.z = current_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(45))
