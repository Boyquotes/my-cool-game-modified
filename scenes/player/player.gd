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
@export var third_person_jitter_lerp_weight: float
@export var other_scene: PackedScene

var h_camera_rotation: Vector3
var v_camera_rotation: Vector3
var movement_state: int
var direction: Vector3

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var h_cam: Node3D = $CameraRig/HCam
@onready var v_cam: Node3D = $CameraRig/HCam/VCam
@onready var Collider: Node3D = $Collider
@onready var mesh_nodes: Node3D = $Collider/mesh_nodes
@onready var camera_rig: Node3D = $CameraRig
@onready var mesh_nodes_offset: Vector3 = transform.origin - mesh_nodes.transform.origin
@onready var camera_rig_offset: Vector3 = transform.origin - camera_rig.transform.origin

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
	#only move camera is mouse is captured to window. Also stops camera from suddenlg moving with centred mouse.
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if (event is InputEventMouseMotion):
		h_cam.rotation.y -= (event.relative.x * 0.01 * (mouse_sensitivity/100))
		Collider.rotation.y = h_cam.rotation.y
		v_cam.rotation.x -= (event.relative.y * 0.01 * (mouse_sensitivity/100))
		v_cam.rotation.x = clamp(v_cam.rotation.x, deg_to_rad(min_camera_angle), deg_to_rad(max_camera_angle))

func _process(delta: float):
	#rotate the mesh to face the direction of the user input
	if ((velocity != Vector3.ZERO) && (direction != Vector3.ZERO)):
		mesh_nodes.rotation.y = lerp_angle(mesh_nodes.rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)
	
	#Solution for removing mesh jitter - make certain nodes top level and lerp positions
	mesh_nodes.transform.origin = damp(mesh_nodes.transform.origin, transform.origin - mesh_nodes_offset, third_person_jitter_lerp_weight, delta)
	camera_rig.transform.origin = damp(camera_rig.transform.origin, transform.origin - camera_rig_offset, third_person_jitter_lerp_weight, delta)
	
func _physics_process(delta: float):
	player_movement(delta)

## Calculates player movement and moves the character body
func player_movement(delta: float):
	# Add the gravity.
	if (not is_on_floor()):
		velocity.y -= (gravity * gravity_acceleration * delta)

	# Handle Jump.
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (h_cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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
	
	move_and_slide()


func _change_scene(_body):
	#get_tree().change_scene_to_packed(other_scene)
	#SaveManagement.save_game()
	pass

func damp(source, target, smoothing, dt):
	return lerp(source, target, 1 - exp(-smoothing * dt))
