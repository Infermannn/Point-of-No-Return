extends Control

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	
func _on_endless_pressed():
	Global.endless_mode = true
	Global.endless_wave = 0
	get_tree().change_scene_to_file("res://level1.tscn")
