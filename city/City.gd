tool
class_name City
extends Sprite

signal clicked(sender)

enum Size {
	XS = 100,
	S = 250,
	M = 500,
	L = 800,
	XL = 1000,
}

const max_inhabitants := 1000
const grid_snap := 64 / 4 # COPY FROM MAPMANAGER

var circle := CircleShape2D.new()

var _editor_position_edited := false


export(Size) var inhabitants : int = 100 setget _set_inhabitants
export(int, 0, 1000, 1) var connected_inhabitants : int = 0 setget _set_connected_inhabitants
export(int, 0, 1000, 1) var est_connected_inhabitants : int = 0 setget _set_est_connected_inhabitants
export(float) var scale_factor : float = 100 setget _set_scale_factor
export(float, 0, 1) var coverage : float = 0 setget _set_coverage, _get_coverage
export var is_router := false setget _set_is_router
export(String) var city_id := ""

onready var area := Area2D.new()
onready var shape := CollisionShape2D.new()
onready var _editor_last_position := position

var _is_ready := false

func _ready() -> void:
	_is_ready = true
	add_child(area)
	area.add_child(shape)
	shape.shape = circle
	circle.radius = get_radius()
	set_process(Engine.editor_hint)
	_update_texture()
	material = preload("res://city/CityMaterial.tres").duplicate()
	self.is_router = is_router
	self.connected_inhabitants = connected_inhabitants
	self.est_connected_inhabitants = est_connected_inhabitants



func _process(delta):
	if not Engine.editor_hint:
		return
	if position != _editor_last_position:
		_editor_last_position = position
		_editor_position_edited = true
		set_process(false)
		yield(get_tree().create_timer(0.2), "timeout")
		set_process(true)
		return
	if _editor_position_edited:
		_editor_position_edited = false
		# We want to position the cities on the grid
		var ofs_x = fmod(position.x, grid_snap)
		var ofs_y = fmod(position.y, grid_snap)
		position.x += -ofs_x if ofs_x < grid_snap / 2 else grid_snap - ofs_x
		position.y += -ofs_y if ofs_y < grid_snap / 2 else grid_snap - ofs_y
		position += Vector2(0.3,0.3)
		_editor_last_position = position
		return
		
	


func _draw() -> void:
	if is_router:
		return
		draw_circle(Vector2.ZERO, get_radius() + get_ring_width()+2, Color.blueviolet)
		draw_circle(Vector2.ZERO, get_radius(), Color(0.8,0.8,0.8))
	else:
		return
		var color := Color(0.8,0.8,0.8) #if coverage == 0 else (Color.gray if coverage < 1 else Color.white)
		draw_circle(Vector2.ZERO, get_radius(), color)
		var end_angle = 2*PI*coverage-0.5*PI
		draw_arc(Vector2.ZERO, get_radius() + get_ring_width(), -0.5*PI, end_angle, 40,
				Color.gray if coverage < 1 else Color.green, get_ring_width(), true)
		if coverage < 1 and est_connected_inhabitants != 0:
			var additional_coverage = (connected_inhabitants + est_connected_inhabitants) / float(inhabitants)
			additional_coverage = 2*PI*additional_coverage-0.5*PI
			draw_arc(Vector2.ZERO, get_radius() + get_ring_width(), end_angle,
					additional_coverage, 40, Color.blue, get_ring_width(), true)


func _unhandled_input(_event) -> void:
	if not Input.is_action_just_released("select"):
		return
	if abs(position.distance_to(get_global_mouse_position())) < get_radius():
		emit_signal("clicked", self)
	pass

static func sort_inhabitants(a, b):
	if a.inhabitants < b.inhabitants:
		return true
	return false


static func get_size_key(inhabitants: int) -> String:
	match inhabitants:
		100:
			return "XS"
		250:
			return "S"
		500:
			return "M"
		800:
			return "L"
		1000:
			return "XL"
		_:
			print("Size is not supported")
			#assert(false)
			return "l"


func get_unconnected_inhabitants() -> int:
	return inhabitants - connected_inhabitants


func get_ring_width() -> float:
	if inhabitants > 800:
		return 5.0
	elif inhabitants > 600:
		return 4.0
	elif inhabitants > 300:
		return 3.0
	else:
		return 2.0

func get_radius() -> float:
	return inhabitants/float(max_inhabitants) * scale_factor


func _set_inhabitants(val : int) -> void:
	inhabitants = val
	circle.radius = get_radius()
	_update_texture()


func _set_est_connected_inhabitants(val : int):
	var max_add = inhabitants - connected_inhabitants
	est_connected_inhabitants = val if val < max_add else max_add
	material.set_shader_param("est_coverage", 
			(connected_inhabitants + est_connected_inhabitants) / float(inhabitants))
	update()


func _set_connected_inhabitants(val : int) -> void:
	connected_inhabitants = val
	coverage = connected_inhabitants / float(inhabitants)
	material.set_shader_param("coverage", coverage)
	self.est_connected_inhabitants = est_connected_inhabitants
	update()


func _set_scale_factor(val : float) -> void:
	scale_factor = val
	circle.radius = get_radius()
	update()


func _set_coverage(val : float) ->void:
	coverage = val
	update()


func _get_coverage() -> float:
	if is_router:
		return 1.0
	return coverage


func get_est_coverage() -> float:
	return min(self.coverage + est_connected_inhabitants / float(inhabitants), 1.0)


func _set_is_router(val : bool) -> void:
	is_router = val
	if !_is_ready:
		return
	material.set_shader_param("is_router", is_router)
	_update_texture()


func _update_texture():
	if is_router:
		texture = load("res://city/router/"+get_size_key(inhabitants).to_lower()+".png")
	else:
		texture = load("res://city/city/"+get_size_key(inhabitants).to_lower()+".png")
	update()
