tool
class_name Cable
extends Node2D

signal cable_clicked(cable)
signal cable_hovered(cable)

enum Size {
	XS = 250,
	S = 500,
	M = 750,
	L = 1000,
	XL = 1250,
}

export(Size) var size := Size.XS setget _set_size
export(float,0.001,1,0.001) var detail : float = 1.0 setget _set_detail #between 0 and 1
export(Color) var color := Color.green setget _set_color
export(float) var line_width : float= 2.0 setget _set_width
export(bool) var curve_antialised := true setget _set_antialised
export var workload := 0 setget _set_workload
export var not_simulated := true
export var broken := false setget set_broken
export var to_position := Vector2(0,0)
export var debug_draw_rect := false

var from_city = null
var to_city = null


var d_tl := Vector2(0,0)
var d_br := Vector2(0,0)
var calbe_rect := Rect2(0,0,0,0)


func _ready():
	pass


func _unhandled_input(_event):
	if Input.is_action_just_released("select") && on_line(get_local_mouse_position()):
		emit_signal("cable_clicked", self)
		return
	if _event is InputEventMouseMotion && on_line(get_local_mouse_position()):
		emit_signal("cable_hovered", self)


func _draw():
	if debug_draw_rect:
		draw_rect(calbe_rect, Color.brown,false,3, true)
	if from_city == null || to_city == null:
		return
	if not_simulated:
		draw_line(Vector2(0,0), to_position, Color.darkblue, line_width, curve_antialised)
		return
	if broken:
		draw_line(Vector2(0,0), to_position, Color.darkgray, line_width, curve_antialised)
		return
	draw_line(Vector2(0,0), to_position, color, line_width, curve_antialised)


func make(from : City, to : City, _size : int):
	from_city = from
	to_city = to
	size = _size
	line_width = size / 100.0
	var p1 = to.position
	position = from.position
	if (p1 - position).length_squared() < 0:
		position = p1
		p1 = from.position
	to_position = Vector2((p1 - position).length(), 0)
	rotation = (p1 - position).angle()
	not_simulated = true
	calbe_rect = Rect2(Vector2(0,-line_width), to_position+Vector2(0,2*line_width))
	update()
	return self


func upgrade(to_size : int) -> int:
	if size == to_size:
		return 0
	self.size = to_size
	self.broken = false
	not_simulated = true
	calbe_rect = Rect2(Vector2(0,-line_width), to_position+Vector2(0,2*line_width))
	update()
	return get_upgrade_costs(to_size)


func repair() -> int:
	broken = false
	not_simulated = true
	update()
	return get_build_costs() / 2


func get_upgrade_costs(to_size) -> int:
	if size == to_size:
		return 0
	var cost := get_build_cost(to_size) - get_build_costs() + get_upgrade_cost(to_size)
	return cost if cost > 0 else 0


static func calc_line_width(size : int) -> float:
	return size / 100.0


static func calc_usage_color(workload : int, size : int) -> Color:
	var wl = workload/float(size)
	if wl <= 0.5:
		return Color(2*wl, 1, 0)
	elif wl > 1:
		return Color.darkgray
	else:
		return Color(1, 1-wl, 0)


static func calc_path_workload(path : Array) -> float:
	var wl : float = 0
	for p in path:
		if wl < p.workload:
			wl = p.workload
	return wl


static func sort_path_length(a, b):
	if a.size() < b.size():
		return true
	if calc_path_workload(a) < calc_path_workload(b):
		return true
	return false


func get_build_costs() -> int:
	return get_build_cost(size)


static func get_upgrade_cost(size : int) -> int:
	match size:
		Size.XS:
			return 0
		Size.S:
			return 200
		Size.M:
			return 300
		Size.L:
			return 400
		Size.XL:
			return 500
	assert("Wrong size")
	return 0


static func get_build_cost(size : int) -> int:
	match size:
		Size.XS:
			return 400
		Size.S:
			return 800
		Size.M:
			return 1000
		Size.L:
			return 1600
		Size.XL:
			return 2000
	assert("Wrong size")
	return 0

func get_maintenance_costs() -> int:
	return get_maintenance_cost(size)


static func get_maintenance_cost(size : int) -> int:
	match size:
		Size.XS:
			return 40
		Size.S:
			return 40
		Size.M:
			return 80
		Size.L:
			return 184
		Size.XL:
			return 240
	assert("Wrong size")
	return 0


func set_broken(_broken := true):
	broken = _broken
	update()

func get_max_workload() -> int:
	return size


func has_free_capacity() -> bool:
	return workload < size


func get_free_capacity() -> int:
	return size - workload


func on_line(point : Vector2) -> bool:
	return calbe_rect.has_point(point)


func _set_size(val : int):
	size = val
	line_width = size / 100.0
	self.workload = workload


func _set_detail(val : float):
	detail = val
	update()

func _set_color(val : Color):
	color = val
	update()

func _set_width(val : float):
	line_width = val
	update()

func _set_antialised(val : bool):
	curve_antialised = val
	update()


func _set_workload(val : int):
	workload = val
	not_simulated = false
	color = calc_usage_color(val, size)
	update()
