extends StaticBody3D

@onready var outline_shader: ShaderMaterial = $mesh_nodes/MeshInstance3D.get_surface_override_material(0).next_pass

var focused: bool = false
var alpha: float = 0

@export var alpha_speed: float = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#set outline shader alpha
	if (focused):
		outline_shader.set_shader_parameter("focused", true)
		alpha += delta * alpha_speed
	else:
		outline_shader.set_shader_parameter("focused", false)
		alpha = 0
		
	alpha = clamp(alpha, 0, 1)
	outline_shader.set_shader_parameter("outline_alpha", alpha)
