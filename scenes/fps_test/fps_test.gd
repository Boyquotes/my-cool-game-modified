extends CharacterBody3D

## Main game character controller script
##
## This script is used to controll all of the character
## game actions and behaviour

#constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var picked_up_item: Node3D
var focused_item: Node3D
var direction: Vector3
var head_global_transform_previous: Transform3D
var head_global_transform_current: Transform3D

#export variables
@export var mouse_sensitivity: float
@export var controller_sensitivity: float
@export var throw_strength: float


#node references
@onready var head: Node3D = $smoothing_node/head
@onready var collision: CollisionShape3D = $collision 
@onready var mesh_nodes: Node3D = $smoothing_node/mesh_nodes
@onready var raycast: RayCast3D = $smoothing_node/head/camera/raycast_interaction
@onready var raycast_hold_position = $smoothing_node/head/camera/raycast_hold_position


func _ready():
	#Engine.max_fps = 10
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
		mesh_nodes.rotation.y = head.rotation.y
		collision.rotation.y = head.rotation.y
		
		#vertical rotation
		head.rotation.x -= (event.relative.y * 0.01 * (mouse_sensitivity/100))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _process(_delta):
	handle_picked_up_item()

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
	
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			if picked_up_item == null:
				select_item_for_picking_up()
			else:
				select_item_for_dropping()
	
	highlight_item()

	move_and_slide()

## Select a highlighted object too allow player to pick it up
func select_item_for_picking_up():
	picked_up_item = raycast.get_collider()
	if picked_up_item is RigidBody3D:
		picked_up_item.freeze = true
		if ("picked" in picked_up_item):
			picked_up_item.picked = true

## Allow picked up object to be dropped
func select_item_for_dropping():
	if picked_up_item is RigidBody3D:
		picked_up_item.freeze = false
		if ("picked" in picked_up_item):
			picked_up_item.picked = false
		
	picked_up_item = null

## Activate the outline shader if the player is within range of
## the interactable object
func highlight_item():
	if raycast.is_colliding():
		if focused_item:
			if focused_item != raycast.get_collider():
				if ("focused" in focused_item): ##unhilight old item
					focused_item.focused = false
					focused_item = null
					focused_item = raycast.get_collider()
				if ("focused" in focused_item): ##highlight new item
					focused_item.focused = true
		else:
			focused_item = raycast.get_collider()
			if ("focused" in focused_item):
				focused_item.focused = true
	else:
		if focused_item:
			if ("focused" in focused_item):
				focused_item.focused = false
				focused_item = null

## 
func handle_picked_up_item():
	if picked_up_item:
		picked_up_item.global_position = raycast_hold_position.global_position
