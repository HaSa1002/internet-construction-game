class_name StartLevel
extends TextureRect

signal start_level_pressed

enum GoalType {
	WEEKS_FULL_COVERAGE,
}

func show_full(level : int, goal_type : int, goal : int):
	$Panel/CenterContainer/VBoxContainer/Level.text = "Level %d" % level
	var gs := ""
	match goal_type:
		GoalType.WEEKS_FULL_COVERAGE:
			gs = "Provide %d weeks full network coverage."
		_:
			gs = "%d"
			print("Unknown goal type")
	$Panel/CenterContainer/VBoxContainer/Goal.text = gs % goal
	show()
	get_tree().paused = true


func show_custom(level : String, description : String):
	$Panel/CenterContainer/VBoxContainer/Level.text = level
	$Panel/CenterContainer/VBoxContainer/Goal.text = description
	show()
	get_tree().paused = true


func _on_StartLevel_pressed():
	hide()
	get_tree().paused = false
	emit_signal("start_level_pressed")
