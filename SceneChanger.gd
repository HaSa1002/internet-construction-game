extends Node

enum Scene {
	MAIN_MENU,
	MAP_MANAGER,
	LEVEL_SELECTION,
	QUIT,
}

var _main_menu := preload("res://ui/main_menu/MainMenu.tscn").instance()
var _map_manager := preload("res://mapmanager/Mapmanager.tscn").instance()
var _levelselection := preload("res://levelselect/levelselect.tscn").instance()

# Only works in Levelselction. When needed see level_selection() and copy _back_top back
var _back_stack : Array = [Scene.QUIT]
var _back_top = null

func _ready():
	pass


func hide_all():
	for child in get_children():
		remove_child(child)
	_back_top = _back_stack.pop_back()


func main_menu():
	get_tree().paused = false
	hide_all()
	add_child(_main_menu)
	_back_stack.push_back(Scene.MAIN_MENU)


func map_manager():
	get_tree().paused = false
	hide_all()
	add_child(_map_manager)
	_back_stack.push_back(Scene.MAP_MANAGER)

func new_game():
	map_manager()
	_map_manager.new_game()


func play_level(level : int):
	map_manager()
	_map_manager.current_level = level


func level_selection():
	get_tree().paused = false
	hide_all()
	add_child(_levelselection)
	_back_stack.push_back(_back_top)
	_back_stack.push_back(Scene.LEVEL_SELECTION)
	_levelselection.show()


func go_back():
	hide_all()
	_back_top = _back_stack.pop_back()
	match _back_top:
		Scene.LEVEL_SELECTION:
			level_selection()
		Scene.MAIN_MENU:
			main_menu()
		Scene.MAP_MANAGER:
			map_manager()
		Scene.QUIT:
			continue
		null:
			continue
		_:
			get_tree().quit(0)


func quit():
	# save
	get_tree().quit(0)
