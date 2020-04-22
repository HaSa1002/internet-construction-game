tool
class_name City
extends Node2D

signal clicked(sender)

const max_inhabitants := 1000

var circle := CircleShape2D.new()

export(int, 0, 1000, 1) var inhabitants : int = 100 setget _set_inhabitants
export(int, 0, 1000, 1) var connected_inhabitants : int = 0 setget _set_connected_inhabitants
export(int, 0, 1000, 1) var est_connected_inhabitants : int = 0 setget _set_est_connected_inhabitants
export(float) var scale_factor : float = 100 setget _set_scale_factor
export(float, 0, 1) var coverage : float = 0 setget _set_coverage, _get_coverage
export var is_router := false setget _set_is_router
export(String) var city_id := ""

onready var area := Area2D.new()
onready var shape := CollisionShape2D.new()


func _ready() -> void:
	add_child(area)
	area.add_child(shape)
	shape.shape = circle
	circle.radius = get_radius()
	pass


func _draw() -> void:
	if is_router:
		draw_circle(Vector2.ZERO, get_radius() + get_ring_width()+2, Color.blueviolet)
		draw_circle(Vector2.ZERO, get_radius(), Color.white)
	else:
		var color := Color.white #Color(0.3,0.3,0.3) if coverage == 0 else (Color.gray if coverage < 1 else Color.white)
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
	update()


func _set_est_connected_inhabitants(val : int):
	var max_add = inhabitants - connected_inhabitants
	est_connected_inhabitants = val if val < max_add else max_add
	update()


func _set_connected_inhabitants(val : int) -> void:
	connected_inhabitants = val
	coverage = connected_inhabitants / float(inhabitants)
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


func _set_is_router(val : bool) -> void:
	is_router = val
	update()
