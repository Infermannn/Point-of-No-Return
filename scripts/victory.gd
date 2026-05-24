extends Control

func _on_try_again_pressed():
	Global.click_player.play()
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_main_menu_pressed():
	Global.click_player.play()
	get_tree().change_scene_to_file("res://menu.tscn")
	
func _on_endless_pressed():
	Global.click_player.play()
	Global.endless_mode = true
	Global.endless_wave = 0
	get_tree().change_scene_to_file("res://level1.tscn")
