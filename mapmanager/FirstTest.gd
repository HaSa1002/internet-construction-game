tool
extends TextureRect

static func vec4(a: Vector2, b: Vector2) -> Color:
	return Color(a.x,a.y,b.x,b.y)

func _process(delta):
	#rect_size.y = rect_size.x
	
	material.set_shader_param("mouse", get_local_mouse_position()/rect_size*(rect_size/texture.get_size().x))
	material.set_shader_param("delta", delta)
#	printt(get_viewport().get_visible_rect(), rect_size/texture.get_size(), get_global_mouse_position(), get_local_mouse_position(), get_local_mouse_position()/rect_size*10.0)
	material.set_shader_param("rects", floor(get_viewport().size.x / 100.0))
	#material.set_shader_param("r_origin", polygon[0])
	#material.set_shader_param("r_size", size*scale)
	#material.set_shader_param("global_transform", global_transform)
