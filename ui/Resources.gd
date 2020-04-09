#tool
class_name Ressources
extends PanelContainer

signal maintenance_changed(value)

var maintenance_factor : float = 1.0 setget set_maintenance_factor
var mouse_wartung := false





func set_build_info(cost : int, _maintenance : int, money : int):
	var mny := $HBoxContainer/Resources/HBoxContainer/Money
	mny.text = "%d €" % cost
	$HBoxContainer/Resources/HBoxContainer2/Maintenance.text = "%d €/W" % int(round(_maintenance * $HBoxContainer/Wartung/HSlider.value))
	$HBoxContainer/Resources/HBoxContainer3/Income.text = "-"
	$HBoxContainer/Resources/HBoxContainer4/Coverage.text = "-"
	if cost <= money:
		mny.add_color_override("font_color",Color.green)
	else:
		mny.add_color_override("font_color",Color.red)


func reset_build_info(money, maintenance, income, coverage):
	var mny := $HBoxContainer/Resources/HBoxContainer/Money
	mny.text = "%d €" % money
	$HBoxContainer/Resources/HBoxContainer2/Maintenance.text = "%d €/W" % maintenance
	$HBoxContainer/Resources/HBoxContainer3/Income.text = "%d €/W" % income
	$HBoxContainer/Resources/HBoxContainer4/Coverage.text = "%d %%" % round(coverage * 100)
	mny.add_color_override("font_color",Color.white)


func set_money(val : int):
	$HBoxContainer/Resources/HBoxContainer/Money.text = "%d €" % val


func set_maintenance(val : int):
	$HBoxContainer/Resources/HBoxContainer2/Maintenance.text = "%d €/W" % val


func set_maintenance_factor(val : float):
	$HBoxContainer/Wartung/HSlider.value = val


func set_income(val : int):
	$HBoxContainer/Resources/HBoxContainer3/Income.text = "%d €/W" % val


func set_coverage(val : float):
	$HBoxContainer/Resources/HBoxContainer4/Coverage.text = "%d %%" % round(val * 100)

func _wartung(visible : bool):
	$HBoxContainer/Wartung.visible = visible
	$HBoxContainer.queue_sort()


func _on_HBoxContainer2_mouse_entered():
	mouse_wartung = true


func _gui_input(_event):
	if Input.is_action_just_released("select"):
		_wartung(mouse_wartung)


func _input(_event):
	if mouse_wartung:
		return
	if !mouse_wartung && Input.is_action_pressed("select"):
		return
	_on_PanelContainer_mouse_exited()


func _on_PanelContainer_mouse_exited():
	if !mouse_wartung || get_global_rect().has_point(get_global_mouse_position()):
		return
	set_size(Vector2(0,0))
	_wartung(false)
	set_size(Vector2(0,0))
	mouse_wartung = false
	


func _on_HSlider_value_changed(value):
	emit_signal("maintenance_changed", value)
