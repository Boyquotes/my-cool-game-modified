extends CharacterBody3D

#enums
enum PlayerState { IDLE, WALKING, RUNNING, STOPPING, JUMPING, FALLING, AIMING, SHOOTING, INTERACTING }

#exported variables
@export var mouse_sensitivity: float
@export var max_camera_angle: float
@export var min_camera_angle: float
@export var speed: float
@export var jump_velocity: float
@export var run_multiplier: float
@export var gravity_acceleration: float
@export var turn_speed: float

var input_vector: Vector2
var h_camera_rotation: Vector3
var v_camera_rotation: Vector3
var movement_state: int

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var h_cam: Node3D = $CameraRig/HCam
@onready var v_cam: Node3D = $CameraRig/HCam/VCam
@onready var collider: CollisionShape3D = $Collider

func _ready():
	#Capture the mouse for user input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	#Set movement state to IDLE
	movement_state = PlayerState.IDLE

func _input(event):
	if event.is_action_pressed("pause"):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event.is_action_pressed("run"):
		movement_state = PlayerState.RUNNING


#Logic for unhandled events
func _unhandled_input(event):
	if (event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		#store input values for camera rotation
		input_vector = -event.relative * mouse_sensitivity

func _process(delta):
	rotate_camera(delta)

func _physics_process(delta):
	player_movement(delta)

## Calculates player movement and moves the character body
func player_movement(delta: float) -> void:
	# Add the gravity.
	if (not is_on_floor()):
		velocity.y -= (gravity * gravity_acceleration * delta)

	# Handle Jump.
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (h_cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#sprinting and walking speeds
	if (direction != Vector3.ZERO and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		if (movement_state == PlayerState.RUNNING):
			velocity.x = direction.x * run_multiplier * speed
			velocity.z = direction.z * run_multiplier * speed
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	#TODO - slow down the player if they let go of the movement buttons	
	else:
		movement_state = PlayerState.IDLE
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	#rotate the character collider to face the direction of the user input
	if (velocity != Vector3.ZERO):
		collider.rotation.y = lerp_angle(collider.rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)
		
	move_and_slide()

## Rotates the camera rig attached to the player based on user input
func rotate_camera(delta: float) -> void:
	#Rotate the camera horizontally
	h_camera_rotation.y += input_vector.x * delta
	h_cam.transform.basis = Basis.from_euler(h_camera_rotation)
	
	#Rotate the camera vertically
	v_camera_rotation.x += input_vector.y * delta
	v_camera_rotation.x = clamp(v_camera_rotation.x, deg_to_rad(min_camera_angle), deg_to_rad(max_camera_angle))
	v_cam.transform.basis = Basis.from_euler(v_camera_rotation)
	
	#reset input vector to stop camera from spinning constantly
	input_vector = Vector2.ZERO
	

