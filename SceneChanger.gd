extends Node

var _main_menu := preload("res://ui/main_menu/MainMenu.tscn").instance()
var _map_manager := preload("res://mapmanager/Mapmanager.tscn").instance()

func _ready():
	pass


func hide_all():
	for child in get_children():
		remove_child(child)
	pass


func main_menu():
	get_tree().paused = false
	hide_all()
	add_child(_main_menu)


func map_manager():
	get_tree().paused = false
	hide_all()
	add_child(_map_manager)

func new_game():
	get_tree().paused = false
	hide_all()
	map_manager()
	_map_manager.new_game()
