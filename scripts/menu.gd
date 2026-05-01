extends Control

func _on_play_pressed():
	Global.current_wave = 0
	Global.player_hp = 400
	Global.player_max_hp = 400
	Global.player_speed = 350
	Global.player_attack_speed = 0.75
	Global.player_attack_damage = 100
	Global.player_bullet_speed = 750
	Global.player_armor = 0
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
