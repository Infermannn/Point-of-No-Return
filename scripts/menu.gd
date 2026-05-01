extends Control

func _on_play_pressed():
	Global.current_wave = 0
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
