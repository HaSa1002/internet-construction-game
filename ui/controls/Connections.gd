extends PanelContainer

signal cable_size_btn_pressed(size)
signal dismantle_pressed
signal repair_pressed
signal repair_all
signal untoggle

export var repair_all_length := 0.5

var last_btn = 0
var _repair_duration := 0.0

onready var xs := $ConnectionControls/XS
onready var s := $ConnectionControls/S
onready var m := $ConnectionControls/M
onready var l := $ConnectionControls/L
onready var xl := $ConnectionControls/XL
onready var repair := $ConnectionControls/Repair


func _ready():
	set_process(false)


func _process(delta):
	_repair_duration += delta
	if _repair_duration < repair_all_length:
		repair.self_modulate = Color((repair_all_length-_repair_duration)/repair_all_length, 
				1.0, (repair_all_length-_repair_duration)/repair_all_length)
	else:
		repair.self_modulate = Color(0.0,1.0,0.0)
	set_process(false)


func _unhandled_input(event):
	if Input.is_action_pressed("repair"):
		set_process(true)
		return
	if Input.is_action_just_released("repair"):
		if _repair_duration >= repair_all_length:
			emit_signal("repair_all")
			unpress_btns()
		_repair_duration = 0
		repair.self_modulate = Color.white


func check_untoggle(btn : int) -> bool:
	if last_btn == btn:
		last_btn = 0
		emit_signal("untoggle")
		return true
	last_btn = btn
	return false


func send_btn_pressed(size : int):
	if check_untoggle(size):
		return
	emit_signal("cable_size_btn_pressed", size)


func unpress_btns():
	last_btn = 0
	for btn in $ConnectionControls.get_children():
		if not btn is BaseButton:
			continue
		btn.pressed = false


func set_colors(btn : BaseButton, color : Color):
	btn.add_color_override("font_color_disabled", color)
	btn.add_color_override("font_color_hover", color)
	btn.add_color_override("font_color_pressed", color)
	btn.add_color_override("font_color", color)


func show_size_hint(inhabitants : int):
	set_colors(xs, Cable.calc_usage_color(inhabitants, Cable.Size.XS))
	set_colors(s, Cable.calc_usage_color(inhabitants, Cable.Size.S))
	set_colors(m, Cable.calc_usage_color(inhabitants, Cable.Size.M))
	set_colors(l, Cable.calc_usage_color(inhabitants, Cable.Size.L))
	set_colors(xl, Cable.calc_usage_color(inhabitants, Cable.Size.XL))


func reset_size_hint():
	for btn in $ConnectionControls.get_children():
		if not btn is BaseButton:
			continue
		set_colors(btn, Color.white)


func _on_XS_pressed():
	send_btn_pressed(Cable.Size.XS)


func _on_S_pressed():
	send_btn_pressed(Cable.Size.S)


func _on_M_pressed():
	send_btn_pressed(Cable.Size.M)


func _on_L_pressed():
	send_btn_pressed(Cable.Size.L)


func _on_XL_pressed():
	send_btn_pressed(Cable.Size.XL)


func _on_Dismantle_pressed():
	if check_untoggle(-1):
		return
	emit_signal("dismantle_pressed")


func _on_Repair_pressed():
	if check_untoggle(-2):
		return
	emit_signal("repair_pressed")
