extends Control

func _on_play_pressed():
	get_tree().change_scene_to_file("res://difficulty.tscn")
	print("changing scene")
	Global.tutorial_done = false
	Global.current_wave = 0
	Global.player_hp = 400
	Global.player_max_hp = 400
	Global.player_speed = 350
	Global.player_attack_speed = 0.75
	Global.player_attack_damage = 100
	Global.player_armor = 0
	Global.player_evasion = 0

func _on_quit_button_pressed():
	get_tree().quit()
	
func _ready():
	Global.stop_music()
	Global.start_menu_music()
	Global.set_music_volume(1.0)
	Global.current_wave = 0
	Global.endless_mode = false
	Global.endless_wave = 0
	Global.endless_enemy_mult = 1.0
	Global.stop_music()
	#update_mute_button()

func _on_mute_button_pressed():
	Global.toggle_mute()
	#update_mute_button()
	
