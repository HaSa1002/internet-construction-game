extends Node2D

export var current_level := 1 setget _set_level

var map : Map



func _ready():
	pass

func _process(_delta):
	set_process(false)
	if map != null:
		remove_child(map)
		map.disconnect("next_level_requested", self, "_on_next_level_requested")
		map.queue_free()
		yield(get_tree(), "idle_frame")
	var m = load(level_path())
	if m == null:
		map = null
		print("Level not found")
		SceneChanger.main_menu()
		return
	map = m.instance()
	add_child(map)
# warning-ignore:return_value_discarded
	map.connect("next_level_requested", self, "_on_next_level_requested")
	

func level_path() -> String:
	match current_level:
		1,2,3,4,5,6,7,8,9:
			return "res://maps/tutorial/tutorial%d.tscn" % current_level
	return ""


func new_game():
	current_level = 1
	set_process(true)


func _set_level(val : int):
	if val == current_level:
		return
	current_level = val
	set_process(true)


func _on_next_level_requested():
	self.current_level += 1