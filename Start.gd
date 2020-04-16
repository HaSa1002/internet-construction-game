extends Node

func _ready():
	# Ensure working working user directory
	if !ensure_path("user://saves"):
		return
	if !ensure_path("user://mods"):
		return
	if !ensure_path("user://levels"):
		return
	if !ensure_config_file("user://settings.cfg"):
		return
	if !ensure_config_file("user://saves/save.cfg"):
		return
	SceneChanger.main_menu()


func ensure_path(path : String) -> bool:
	var dir = Directory.new()
	var err = dir.open(path)
	if err != OK:
		print("Directory not present. Making one")
		err = dir.make_dir(path)
		if err != OK:
			print("Directory creating failed with ", err)
			return false
	return true


func ensure_file(path : String) -> bool:
	var file = File.new()
	var err = file.open(path, File.READ)
	if err != OK:
		print("File not present. Making one")
		err = file.open(path, File.WRITE)
		if err != OK:
			print("File creation failed with ", err)
			return false
	return true


func ensure_config_file(path : String) -> bool:
	var file = ConfigFile.new()
	var err = file.load(path)
	if err != OK:
		print("Configfile not present. Making one")
		err = file.save(path)
		if err != OK:
			print("File creation failed with ", err)
			return false
	return true
