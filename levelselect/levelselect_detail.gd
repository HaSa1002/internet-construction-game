class_name LevelSelectDetail
extends Control
#
# Document class
#

# signals
signal selected(level)
signal back_requested

# enums

# constants

# exported variables
export var start_level := 1 setget set_start_level

# public variables

# private _variables

# onready variables


func _ready():
	for i in range(10):
		get_node(str(i)).connect("pressed", self, "_on_x_pressed", [i])
	pass

# other built-in virtual methods

# public methods
func set_start_level(lvl : int):
	start_level = lvl
	_update_content()
	

# private _methods
func _update_content():
	for i in range(10):
		var btn: Button = get_node(str(i))
		btn.text = str(start_level + i)
		btn.disabled = start_level + i > Mapmanager.DEBUG_HIGHEST_LEVEL
	$Label.text = "Level %d-%d" % [start_level, start_level+9]


func _on_Back_pressed():
	emit_signal("back_requested")


func _on_x_pressed(lvl : int):
	emit_signal("selected", lvl+start_level)
