class_name Levelselect
extends Control
#
# Document class
#

# signals

# enums

# constants

# exported variables

# public variables

# private _variables
var _leveldetail : LevelSelectDetail = preload("res://levelselect/levelselect_detail.tscn").instance()

# onready variables

func _ready():
	for i in range(10):
		var btn : Button = get_node("Self/%d"%i)
		btn.connect("pressed", self, "_on_x_pressed", [i*10 + 1])
		btn.disabled = i*10 + 1 > Mapmanager.DEBUG_HIGHEST_LEVEL
	add_child(_leveldetail)
	_leveldetail.hide()
	_leveldetail.connect("back_requested", self, "_on_leveldetail_back_requested")
	_leveldetail.connect("selected", self, "_on_level_selected")
	pass

# other built-in virtual methods

# public methods
func show():
	.show()
	$Self.show()

# private _methods
func _on_x_pressed(lvl : int):
	_leveldetail.start_level = lvl
	_leveldetail.show()
	$Self.hide()
	pass


func _on_leveldetail_back_requested():
	_leveldetail.hide()
	$Self.show()


func _on_level_selected(lvl : int):
	_leveldetail.hide()
	SceneChanger.play_level(lvl)
	pass


func _on_Back_pressed():
	SceneChanger.go_back()
