extends Control

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://world.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
