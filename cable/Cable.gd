tool
class_name Cable
extends Sprite

signal cable_clicked(cable)
signal cable_hovered(cable)

enum Size {
	XS = 250,
	S = 500,
	M = 750,
	L = 1000,
	XL = 1250,
}

const ParticleSize = {
	Size.XS: 2.2,
	Size.S: 4,
	Size.M: 5,
	Size.L: 6,
	Size.XL: 6,
}

const CableSize = {
	Size.XS: 5,
	Size.S: 7,
	Size.M: 9.5,
	Size.L: 12,
	Size.XL: 14.5,
}

export(Size) var size := Size.XS setget _set_size
export(float,0.001,1,0.001) var detail : float = 1.0 setget _set_detail #between 0 and 1
export(Color) var color := Color.green setget _set_color
export(float) var line_width : float= 2.0 setget _set_width
export(bool) var curve_antialised := true setget _set_antialised
export var workload := 0 setget _set_workload
export var not_simulated := true setget _set_simulated
export var broken := false setget set_broken
export var to_position := Vector2(0,0)
export var flipped_flow := false setget _set_flipped_flow
export var debug_draw_rect := false # Todo: Draw in separate Node

# Todos: Offset center considering the seeable cable
# Todos: Fix Cable On Click and resize

var from_city = null
var to_city = null
var particles := Particles2D.new()


var d_tl := Vector2(0,0)
var d_br := Vector2(0,0)
var calbe_rect := Rect2(0,0,0,0)

func _init():
	texture = preload("res://mapmanager/blank.png")
	material = preload("res://cable/CableMaterial.tres").duplicate()
	(material as ShaderMaterial).set_shader_param("size", 0.7)
	offset.y = -0.5
	centered = false
	
	# Set up Particles
	particles.process_material = preload("res://cable/CableParticles.tres")
	particles.show_behind_parent = true
	particles.local_coords = false
	particles.preprocess = 2
	particles.emitting = false


func _ready():
	add_child(particles)
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
	return
	if from_city == null || to_city == null:
		return
	if not_simulated:
		draw_line(Vector2(0,0), to_position, Color.white, line_width, curve_antialised)
		return
	if broken:
		draw_line(Vector2(0,0), to_position, Color.darkgray, line_width, curve_antialised)
		return
	draw_line(Vector2(0,0), to_position, color, line_width, curve_antialised)


func make(from : City, to : City, _size : int):
	from_city = from
	to_city = to
	self.size = _size
	var p1 = to.position
	position = from.position
	if (p1 - position).length_squared() < 0:
		position = p1
		p1 = from.position
	to_position = Vector2((p1 - position).length(), 0)
	# We can cheat here
	scale.x = to_position.x - to.get_radius() - from.get_radius() + 6
	rotation = (p1 - position).angle()
	move_local_x(from.get_radius() - 3)
	self.not_simulated = true
	calbe_rect = Rect2(Vector2(0,-line_width), to_position+Vector2(0,2*line_width))
	notify_city_connection(size)
	update()
	return self


func upgrade(to_size : int) -> int:
	if size == to_size:
		return 0
	self.broken = false
	calbe_rect = Rect2(Vector2(0,-line_width), to_position+Vector2(0,2*line_width))
	var upgrade_cost = get_upgrade_costs(to_size)
	notify_city_connection(to_size - size)
	self.size = to_size
	self.not_simulated = true
	update()
	return upgrade_cost


func notify_city_connection(gain : int):
	if from_city.get_est_coverage() < 1:
		from_city.est_connected_inhabitants += gain
	else:
		to_city.est_connected_inhabitants += gain


func repair() -> int:
	self.broken = false
	self.not_simulated = true
	notify_city_connection(size)
	update()
	return get_build_costs() / 2


func get_upgrade_costs(to_size) -> int:
	if size == to_size:
		return 0
	var cost := get_build_cost(to_size) - get_build_costs() + get_upgrade_cost(to_size)
	return cost if cost > 0 else 0


static func calc_line_width(size : int) -> float:
	return CableSize[size]


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
	(material as ShaderMaterial).set_shader_param("broken", broken)
	particles.emitting = !broken
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
	var ol = line_width
	line_width = calc_line_width(val)
	(particles.process_material as ParticlesMaterial).scale = ParticleSize[val]
	scale.y += line_width - ol
	
	# Update Usage
	self.workload = workload


func _set_detail(val : float):
	detail = val
	update()


func _set_flipped_flow(val: bool):
	if val == flipped_flow:
		return
	if val:
		particles.position.x = 1
		particles.rotation_degrees = 180
		flipped_flow = true
		return
	particles.position.x = 0
	particles.rotation = 0
	flipped_flow = false


func _set_color(val : Color):
	color = val
	update()

func _set_width(val : float):
	line_width = val
	update()

func _set_antialised(val : bool):
	curve_antialised = val
	update()


func _set_simulated(val: bool):
	not_simulated = val
	particles.emitting = !val


func _set_workload(val : int):
	workload = val
	self.not_simulated = false
	var wl = workload/float(size)
	if wl == 0:
		particles.amount = 150 * wl if 150 * wl >= 1 else 2
		particles.speed_scale = 0
	else:
		particles.amount = 150 * wl if 150 * wl >= 1 else 2
		particles.speed_scale = 1.1-wl
	color = calc_usage_color(val, size)
	update()
