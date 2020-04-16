extends TextureRect



func _on_Quit_pressed():
	SceneChanger.quit()


func _on_NewGame_pressed():
	SceneChanger.new_game()


func _on_Continue_pressed():
	SceneChanger.map_manager()


func _on_Levelselection_pressed():
	SceneChanger.level_selection()
