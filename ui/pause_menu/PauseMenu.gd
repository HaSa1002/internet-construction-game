extends TextureRect

signal restart_pressed

func _unhandled_key_input(event):
	if Input.is_action_just_released("pause"):
		switch()


func switch():
	self.visible = !visible
	get_tree().paused = visible


func _on_Continue_pressed():
	get_tree().paused = false
	hide()


func _on_Quit_pressed():
	SceneChanger.quit()


func _on_Restart_pressed():
	get_tree().paused = false
	hide()
	emit_signal("restart_pressed")


func _on_MainMenu_pressed():
	hide()
	SceneChanger.main_menu()


func _on_LevelSelection_pressed():
	hide()
	SceneChanger.level_selection()
