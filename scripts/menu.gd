extends Control

var tex1: Texture2D
var tex2 = preload("res://Textures/buttons/mute2.png")

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
	Global.click_player.play()
	Global.active_perks = []
	Global.glass_cannon = false
	Global.bait_them = false
	Global.damage_reduction = 0
	Global.active_camo = false
	Global.secondary_turrets = false
	Global.pierce = false
	Global.ricochet = false
	Global.explosive_rounds = false
	Global.hydra = false
	Global.repair_drones = false
	Global.last_stand = false
	Global.last_stand_used = false
	Global.focus = false
	Global.bullet_shield = false
	Global.bullet_scale = 1.0
	Global.extra_upgrade_points = 0

func _on_quit_button_pressed():
	Global.click_player.play()
	get_tree().quit()
	
func _ready():
	$BlackScreen.color = Color(0, 0, 0, 1)
	Global.menu_music_player.volume_db = -80
	Global.start_menu_music()
	
	var tween = create_tween()
	tween.tween_property($BlackScreen, "color:a", 0.0, 1.5)
	tween.parallel().tween_method(
		func(vol): Global.menu_music_player.volume_db = vol,
		-80.0, -40.0, 1.5
	)
	tex1 = $MuteButton.texture_normal
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
	Global.play_click()
	Global.toggle_mute()
	$MuteButton.texture_normal = tex2 if $MuteButton.texture_normal == tex1 else tex1
	#update_mute_button()
	Global.click_player.play()


	
