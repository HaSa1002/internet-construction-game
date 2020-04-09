extends Control

signal retry_pressed
signal next_level_pressed

func show_full(title : String, reason : String, next_level := false):
	$Panel/CenterContainer/VBoxContainer/GameOver.text = title
	$Panel/CenterContainer/VBoxContainer/Reason.text = reason
	$Panel/HBoxContainer/NextLevel.visible = next_level
	get_tree().paused = true
	show()


func _on_Retry_pressed():
	hide()
	get_tree().paused = false
	emit_signal("retry_pressed")


func _on_NextLevel_pressed():
	get_tree().paused = false
	emit_signal("next_level_pressed")
