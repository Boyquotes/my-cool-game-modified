extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var mouse_sensitivity: float
@export var controller_sensitivity: float
@export var first_person_jitter_lerp_weight: float

@onready var head: Node3D = $head
@onready var collision: CollisionShape3D = $collision 
@onready var mesh_nodes: Node3D = $collision/mesh_nodes
@onready var head_offset: Vector3 = transform.origin - head.transform.origin
@onready var mesh_nodes_offset: Vector3 = transform.origin - mesh_nodes.transform.origin

var direction: Vector3

func _ready():
	#Capture the mouse for user input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event.is_action_pressed("pause"):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	#only move camera is mouse is captured to window. Also stops camera from suddenlg moving with centred mouse.
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		#horizontal rotation
		head.rotation.y -= (event.relative.x * 0.01 * (mouse_sensitivity/100))
		collision.rotation.y = head.rotation.y
		mesh_nodes.rotation.y = head.rotation.y
		
		#vertical rotation
		head.rotation.x -= (event.relative.y * 0.01 * (mouse_sensitivity/100))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _process(delta):
	#Solution for removing mesh jitter - make certain nodes top level and lerp positions
	mesh_nodes.transform.origin = damp(mesh_nodes.transform.origin, transform.origin - mesh_nodes_offset, first_person_jitter_lerp_weight, delta)
	head.transform.origin = damp(head.transform.origin, transform.origin - head_offset, first_person_jitter_lerp_weight, delta)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func damp(source, target, smoothing, dt):
	return lerp(source, target, 1 - exp(-smoothing * dt))
