extends Control

func _on_try_again_pressed():
	Global.set_music_volume(1.0)
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	
func _ready():
		Global.set_music_volume(0.25)
