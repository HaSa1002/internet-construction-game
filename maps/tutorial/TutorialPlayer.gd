class_name TutorialPlayer
extends AnimationPlayer


func _ready():
	hide_all()


func hide_all():
	for child in $"../CanvasLayer".get_children():
		child.hide()


func end():
	seek(current_animation_length, true)



func _on_ui_start_level_pressed():
	play("begin")


func _on_ui_retry_pressed():
	end()
	hide_all()
	play("begin")
