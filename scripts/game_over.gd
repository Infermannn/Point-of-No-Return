extends Control

func _on_try_again_pressed():
	Global.play_click()
	Global.set_music_volume(1.0)
	var black = ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.size = Vector2(1920, 1080)
	black.z_index = 100
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	Global.start_music() 
	Global.player_hp = Global.player_max_hp
	
	var tween = create_tween()
	tween.tween_property(black, "color:a", 1.0, 1.0)
	await tween.finished
	
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	
func _ready():
	Global.stop_music()
	Global.stop_boss_music()
	var game_over_music = AudioStreamPlayer.new()
	game_over_music.stream = preload("res://Music/Last_Ship_Save.mp3")
	game_over_music.volume_db = -40
	add_child(game_over_music)
	game_over_music.play()
	print("BlackScreen color: ", $BlackScreen.color)
	var tween = create_tween()
	tween.tween_property($BlackScreen, "color:a", 0.0, 1.0)
	print("tween started")
