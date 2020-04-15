extends CanvasLayer

signal cable_size_btn_pressed(size)
signal maintenance_changed(value)
signal dismantle_pressed
signal repair_pressed
signal retry_pressed
signal next_level_pressed
signal start_level_pressed
signal timer_pressed
signal buttons_untoggled


var money := 0
var maintenance := 0
var maintenance_factor := 1.0
var income := 0
var coverage := 0.0
var build_info_displayed := false


func reset_ui():
	$BuildHighlight.hide()
	$DismantleHighlight.hide()
	$RepairHighlight.hide()
	reset_build_info()
	reset_size_hint()


func show_size_hint(inhabitants : int):
	$ConnectionControls.show_size_hint(inhabitants)


func reset_size_hint():
	$ConnectionControls.reset_size_hint()


func update_timer(cov_weeks : int, vic_weeks : int):
	$Timer.update_timer(cov_weeks, vic_weeks)


func reset_timer(vic_weeks : int):
	$Timer.reset_timer(vic_weeks)


func game_over():
	$GameOver.show_full("Game Over", "You ran out of money!")


func won():
	$GameOver.show_full("You won", "You are now a full featured internet provider!", true)


func won_custom(title : String, description : String):
	$GameOver.show_full(title, description, true)


func start_level(level : int, goal_type : int, goal : int):
	$StartLevel.show_full(level, goal_type, goal)

func start_level_custom(level : String, description : String):
	$StartLevel.show_custom(level, description)


func set_build_info(cost : int, maintenance : int):
	build_info_displayed = true
	$Resources.set_build_info(cost, maintenance, money)


func reset_build_info():
	build_info_displayed = false
	$Resources.reset_build_info(money, maintenance, income, coverage)


func untoggle():
	reset_ui()
	$ConnectionControls.unpress_btns()


func set_money(val : int):
	money = val
	if build_info_displayed:
		return
	$Resources.set_money(val)


func set_maintenance(val : int):
	maintenance = val
	if build_info_displayed:
		return
	$Resources.set_maintenance(val)


func set_maintenance_factor(val : float):
	maintenance_factor = val
	if build_info_displayed:
		return
	$Resources.set_maintenance_factor(val)


func set_income(val : int):
	income = val
	if build_info_displayed:
		return
	$Resources.set_income(val)


func set_coverage(val : float):#
	coverage = val
	if build_info_displayed:
		return
	$Resources.set_coverage(val)


func _on_ConnectionControls_dismantle_pressed():
	reset_ui()
	$DismantleHighlight.show()
	emit_signal("dismantle_pressed")


func _on_ConnectionControls_repair_pressed():
	reset_ui()
	$RepairHighlight.show()
	emit_signal("repair_pressed")


func _on_ConnectionControls_cable_size_btn_pressed(size):
	reset_ui()
	$BuildHighlight.show()
	set_build_info(Cable.get_build_cost(size), Cable.get_maintenance_cost(size))
	emit_signal("cable_size_btn_pressed", size)


func _on_GameOver_next_level_pressed():
	emit_signal("next_level_pressed")


func _on_restart_pressed():
	reset_ui()
	emit_signal("retry_pressed")


func _on_Resources_maintenance_changed(value):
	maintenance_factor = value
	emit_signal("maintenance_changed", value)


func _on_Timer_pressed():
	reset_ui()
	$Timer.show_simulate()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	emit_signal("timer_pressed")


func _on_StartLevel_start_level_pressed():
	emit_signal("start_level_pressed")



func _on_ConnectionControls_untoggle():
	untoggle()
	emit_signal("buttons_untoggled")
