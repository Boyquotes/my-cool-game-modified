extends CharacterBody3D

#enums
enum Player_State { IDLE, WALKING, RUNNING, STOPPING, JUMPING, SPRINTING, FALLING, AIMING, SHOOTING, INTERACTING }

#exported variables
@export var _sensitivity: float
@export var _max_camera_angle: float
@export var _min_camera_angle: float
@export var _speed: float
@export var _jump_velocity: float
@export var _speed_multiplier: float
@export var _gravity_acceleration: float
@export var _turn_weight: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var h_cam: Node3D = $CameraRig/HCam
@onready var v_cam: Node3D = $CameraRig/HCam/VCam
@onready var collider: CollisionShape3D = $Collider

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("pause"):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	#TODO - add sprint logic with acceleration/deceleration
	if event.is_action_pressed("sprint"):
		pass
	
#Logic for unhandled events
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		#rotate camera horizontally
		h_cam.rotation.y -= event.relative.x * 0.01 * _sensitivity
		
		#rotate camera vertically
		v_cam.rotation.x -= event.relative.y * 0.01 * _sensitivity
		v_cam.rotation.x = clamp(v_cam.rotation.x, deg_to_rad(_min_camera_angle), deg_to_rad(_max_camera_angle))
		
func _process(_delta):
	#TODO - camera rotation movement to move
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= (gravity * _gravity_acceleration * delta)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (h_cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)
		
	#TODO - rotation of the collision shape and mesh
	if (velocity != Vector3.ZERO):
		collider.rotation.y = h_cam.rotation.y

	move_and_slide()
	
	
func rotate_camera():
	pass
