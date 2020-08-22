class_name Map
extends Node2D

signal next_level_requested
signal cable_built(cable)
signal cable_upgraded(cable)
signal cable_repaired(cable)

var connecting := false
var connect_city : City = null
var connect_size : int
var dismantling := false
var repairing := false
var weeks_with_full_coverage := 0
var ready = false
var build_line_color := Color.white
var on_cable := 0
var moved := 0
var block_build_events := false

export var level : int = 1
export var level_name := ""
export(String, MULTILINE) var description := ""
export var won_title := ""
export(String, MULTILINE) var won_text := ""
export var node_costs_fixed := true
export var node_costs := 300 setget , _get_node_costs
export var victory_weeks := 1

export var money := 20000 setget _set_money
export var maintenance := 20 setget _set_maintenance
export var maintenance_factor : float = 1.0 setget _set_maintenance_factor
export var ensure_full_maintenance := false
export var income := 30 setget _set_income
export var income_factor := 1.0
export var coverage : float = 0.0 setget _set_coverage

onready var r_money := money
onready var r_maintenance := maintenance
onready var r_maintenance_factor := maintenance_factor
onready var r_income := income
onready var r_coverage := coverage
onready var cables := Node2D.new()
onready var simulation := Simulation.new($Cities)

func _ready() -> void:
	ready = true
	cables.show_behind_parent = true
	cables.name = "Cables"
	var cities = $Cities
	remove_child(cities)
	add_child(cables)
	add_child(cities)
	for _city in $Cities.get_children():
		var city := _city as City
		city.connect("clicked", self, "_on_city_clicked")
	$ui.connect("repair_all_pressed", self, "_on_ui_repair_all_pressed")
	reset_state()


func _unhandled_input(_event):
	if Input.is_action_just_released("cancel_cable"):
		if connect_city != null:
			connect_city = null
			$ui.reset_size_hint()
		else:
			reset_interaction()
			$ui.untoggle()
	if _event is InputEventMouseMotion:
		moved += 1
		if connecting:
			update()


func _process(delta):
	block_build_events = false
	var oc = on_cable > moved
	if !oc && connecting:
		$ui.set_build_info(Cable.get_build_cost(connect_size), int(Cable.get_maintenance_cost(connect_size)*maintenance_factor))
		on_cable = 0
		moved = 0
	elif !oc:
		$ui.reset_build_info()
		on_cable = 0
		moved = 0


func _draw():
	if connect_city == null:
		return
	draw_line(connect_city.position, get_global_mouse_position(), build_line_color, 
			Cable.calc_line_width(connect_size), true)


func simulate():
	var sim = simulation.simulate(cables.get_children(), maintenance_factor, ensure_full_maintenance)
	self.income = sim["income"] * income_factor
	self.maintenance = sim["maintenance"] + sim["router_size"] * self.node_costs
	self.coverage = sim["coverage"]
	self.money += income - maintenance


func reset_interaction():
	connect_city = null
	connecting = false
	dismantling = false
	repairing = false
	$ui.reset_size_hint()
	update()


func reset_state():
	for cnt in cables.get_children():
		cnt.queue_free()
	self.maintenance = r_maintenance
	self.maintenance_factor = r_maintenance_factor
	self.income = r_income
	self.coverage = r_coverage
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	simulate()
	self.money = r_money
	weeks_with_full_coverage = 0
	$ui.reset_timer(victory_weeks)
	reset_interaction()
	if description == "":
		$ui.start_level(level, StartLevel.GoalType.WEEKS_FULL_COVERAGE, victory_weeks)
	else:
		$ui.start_level_custom(level_name if level_name != "" else "Level %d" % level, description)


func is_cable_valid(from : City, to : City) -> bool:
	var rc := RayCast2D.new()
	add_child(rc)
	rc.add_exception(from.area)
	rc.add_exception(to.area)
	rc.position = from.position
	rc.cast_to = to.position - from.position
	rc.collide_with_areas = true
	rc.collide_with_bodies = false
	rc.force_raycast_update()
	remove_child(rc)
	return !rc.is_colliding()


func _get_node_costs() -> int:
	if node_costs_fixed:
		return node_costs
	return int(round(node_costs * (1.5 - exp(-3*coverage))))


func _find_cable(from : City, to : City):
	for cnt in cables.get_children():
		if (cnt.from_city == from || cnt.to_city == from) && (cnt.from_city == to || cnt.to_city == to):
			return cnt
	return null


func _repair_cable(cable : Cable) -> bool:
	if money < cable.get_build_costs() / 2:
		return false
	self.money -= cable.repair()
	emit_signal("cable_repaired", cable)
	return true


func _deny_build():
	build_line_color = Color.red
	update()
	yield(get_tree().create_timer(0.3), "timeout")
	build_line_color = Color.white
	update()


func _set_money(val : int):
	money = val
	if !ready:
		return
	$ui.set_money(val)


func _set_maintenance(val : int):
	maintenance = val
	if !ready:
		return
	$ui.set_maintenance(val)


func _set_maintenance_factor(val : float):
	maintenance_factor = val
	if !ready:
		return
	$ui.set_maintenance_factor(val)


func _set_income(val : int):
	income = val
	if !ready:
		return
	$ui.set_income(val)


func _set_coverage(val : float):
	coverage = val
	if !ready:
		return
	$ui.set_coverage(val)


func _on_city_clicked(city : City) -> void:
	if !connecting:
		return
	if block_build_events:
		return
	block_build_events = true
	if connect_city == null:
		connect_city = city
		$ui.show_size_hint(city.get_unconnected_inhabitants())
		return
	if connect_city == city:
		return
	var c : Cable = _find_cable(connect_city, city)
	if c != null:
		if c.get_upgrade_costs(connect_size) <= money:
			var size_before = c.size
			self.money -= c.upgrade(connect_size)
			self.maintenance += (c.get_maintenance_costs() - c.get_maintenance_cost(size_before)) * maintenance_factor
			emit_signal("cable_upgraded", c)
			if Input.is_action_pressed("place_multiple"):
				connect_city = city
			else:
				connect_city = null
			update()
		else:
			_deny_build()
		return
	if Cable.get_build_cost(connect_size) > money:
		_deny_build()
		return
	if !is_cable_valid(connect_city, city):
		_deny_build()
		return
	c = Cable.new()
	c.make(connect_city, city, connect_size)
	c.connect("cable_clicked",self, "_on_Cable_clicked")
	c.connect("cable_hovered",self, "_on_Cable_hovered")
	cables.add_child(c)
	self.money -= c.get_build_costs()
	self.maintenance += c.get_maintenance_costs() * maintenance_factor
	if Input.is_action_pressed("place_multiple"):
		connect_city = city
	else:
		connect_city = null
		update()
	emit_signal("cable_built", c)


func _on_Cable_clicked(cable : Cable):
	if block_build_events:
		return
	block_build_events = true
	if dismantling:
		cable.queue_free()
		return
	if repairing && cable.broken:
		_repair_cable(cable)
		return
	if connecting && connect_city == null:
		if cable.get_upgrade_costs(connect_size) <= money:
			var size_before = cable.size
			self.money -= cable.upgrade(connect_size)
			self.maintenance += (cable.get_maintenance_costs() - cable.get_maintenance_cost(size_before)) * maintenance_factor
			emit_signal("cable_upgraded", cable)
		return


func _on_Cable_hovered(cable : Cable):
	# Exit detection
	on_cable += 1
	moved = on_cable - 2
	set_process(true)
	
	if dismantling:
		$ui.set_build_info(0,-int(cable.get_maintenance_costs() * maintenance_factor))
		return
	if repairing && cable.broken:
		$ui.set_build_info(cable.get_build_costs() / 2,int(cable.get_maintenance_costs() * maintenance_factor))
		return
	if connecting && connect_city == null: # Upgrade
		$ui.set_build_info(cable.get_upgrade_costs(connect_size),
				int((Cable.get_maintenance_cost(connect_size) - cable.get_maintenance_costs()) * maintenance_factor))
		$ui.show_size_hint(cable.workload)
		return


func _on_ui_dismantle_pressed():
	reset_interaction()
	dismantling = true


func _on_ui_next_level_pressed():
	emit_signal("next_level_requested")


func _on_ui_retry_pressed():
	reset_state()


func _on_ui_repair_pressed():
	reset_interaction()
	repairing = true


func _on_ui_repair_all_pressed():
	reset_interaction()
	for cable in cables.get_children():
		if !cable.broken:
			continue
		if !_repair_cable(cable):
			break


func _on_ui_timer_pressed():
	reset_interaction()
	simulate()
	if money < 0:
		$ui.game_over()
	if coverage == 1:
		weeks_with_full_coverage += 1
	else:
		weeks_with_full_coverage = 0
	if weeks_with_full_coverage >= victory_weeks:
		if won_text != "":
			$ui.won_custom(won_title, won_text)
		else:
			$ui.won()
	$ui.update_timer(weeks_with_full_coverage, victory_weeks)


func _on_ui_cable_size_btn_pressed(size):
	dismantling = false
	repairing = false
	$ui.reset_size_hint()
	connecting = true
	connect_size = size
	update()



func _on_ui_maintenance_changed(value):
	self.maintenance_factor = value


func _on_ui_buttons_untoggled():
	reset_interaction()
