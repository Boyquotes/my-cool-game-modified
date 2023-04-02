extends RigidBody3D

@onready var mesh_nodes: Node3D = $mesh_nodes
@onready var target_node: Node3D = $mesh_target

var mesh_global_transform_previous: Transform3D
var mesh_global_transform_current: Transform3D
var update: bool
 ## User is focusing on the object
var focused: bool = false
## User has picked up the object
var picked: bool = false

func _ready():
	mesh_nodes.global_transform = target_node.global_transform
	mesh_global_transform_previous = target_node.global_transform
	mesh_global_transform_current = target_node.global_transform

func _process(_delta):
	if picked:
		mesh_nodes.global_transform = target_node.global_transform
		mesh_global_transform_previous = target_node.global_transform
		mesh_global_transform_current = target_node.global_transform
	else:
		if update:
			update_mesh_transform()
			update = false

		var weight: float = clamp(Engine.get_physics_interpolation_fraction(), 0, 1)
		mesh_nodes.global_transform = mesh_global_transform_previous.interpolate_with(mesh_global_transform_current, weight)

func _physics_process(_delta):
	if !picked:
		update = true
	else:
		update = false

## Update the previous and current mesh transforms
func update_mesh_transform():
	mesh_global_transform_previous = mesh_global_transform_current
	mesh_global_transform_current = target_node.global_transform
