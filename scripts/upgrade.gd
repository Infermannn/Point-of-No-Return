extends Control

func _on_button_pressed():
	Global.player_speed += 50

func _on_button_2_pressed():
	Global.bullet_damage += 50

func _on_button_3_pressed():
	Global.max_lives += 1

func _on_button_4_pressed():
	Global.current_level += 1
	Global.save()
	get_tree().change_scene_to_file("res://level1.tscn")
