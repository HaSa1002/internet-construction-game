extends TextureRect



func _on_Quit_pressed():
	get_tree().quit(0)


func _on_NewGame_pressed():
	SceneChanger.new_game()


func _on_Continue_pressed():
	SceneChanger.map_manager()
