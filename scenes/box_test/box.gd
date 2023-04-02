extends StaticBody3D

@onready var outline_shader: ShaderMaterial = $mesh_nodes/MeshInstance3D.get_surface_override_material(0).next_pass

var focused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if (focused):
		outline_shader.set_shader_parameter("focused", true)
	else:
		outline_shader.set_shader_parameter("focused", false)
