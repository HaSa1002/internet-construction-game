tool
class_name City
extends Node2D

signal clicked(sender)

const max_inhabitants := 1000

var circle := CircleShape2D.new()

export(int, 0, 1000, 1) var inhabitants : int = 100 setget _set_inhabitants
export(int, 0, 1000, 1) var connected_inhabitants : int = 0 setget _set_connected_inhabitants
export(float) var scale_factor : float = 100 setget _set_scale_factor
export(float, 0, 1) var coverage : float = 0 setget _set_coverage
export var is_router := false setget _set_is_router
export(String) var city_id := ""

onready var area := Area2D.new()
onready var shape := CollisionShape2D.new()


func _ready() -> void:
	add_child(area)
	area.add_child(shape)
	shape.shape = circle
	circle.radius = inhabitants/float(max_inhabitants) * scale_factor
	pass


func _draw() -> void:
	if is_router:
		draw_circle(Vector2.ZERO, 5+(inhabitants/float(max_inhabitants) * scale_factor), Color.blueviolet)
		draw_circle(Vector2.ZERO, inhabitants/float(max_inhabitants) * scale_factor, Color.white)
	else:
		draw_circle(Vector2.ZERO, inhabitants/float(max_inhabitants) * scale_factor, Color(coverage,coverage,coverage))


func _unhandled_input(_event) -> void:
	if not Input.is_action_just_released("select"):
		return
	if abs(position.distance_to(get_global_mouse_position())) < inhabitants/float(max_inhabitants) * scale_factor:
		emit_signal("clicked", self)
	pass

static func sort_inhabitants(a, b):
	if a.inhabitants > b.inhabitants:
		return true
	return false


func get_unconnected_inhabitants() -> int:
	return inhabitants - connected_inhabitants


func _set_inhabitants(val : int) -> void:
	inhabitants = val
	circle.radius = inhabitants/float(max_inhabitants) * scale_factor
	update()


func _set_connected_inhabitants(val : int) -> void:
	connected_inhabitants = val
	coverage = connected_inhabitants / float(inhabitants)
	update()


func _set_scale_factor(val : float) -> void:
	scale_factor = val
	circle.radius = inhabitants/float(max_inhabitants) * scale_factor
	update()


func _set_coverage(val : float) ->void:
	coverage = val
	update()


func _set_is_router(val : bool) -> void:
	is_router = val
	update()
