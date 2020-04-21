tool
extends Control

static func vec4(a: Vector2, b: Vector2) -> Color:
	return Color(a.x,a.y,b.x,b.y)

func _process(delta):
	rect_size.y = rect_size.x
	material.set_shader_param("mouse", get_local_mouse_position()/rect_size)
	material.set_shader_param("delta", delta)
	#printt(get_viewport().size, get_viewport().get_mouse_position())
	material.set_shader_param("rects", floor(get_viewport().size.x / 100.0))
	#material.set_shader_param("r_origin", polygon[0])
	#material.set_shader_param("r_size", size*scale)
	#material.set_shader_param("global_transform", global_transform)
