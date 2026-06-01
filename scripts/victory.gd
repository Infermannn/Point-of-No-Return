extends Control

func _ready():
	$BlackScreen.color = Color(0, 0, 0, 1)
	
	var tween = create_tween()
	tween.tween_property($BlackScreen, "color:a", 0.0, 1.0)
	await tween.finished
	
	await shake_and_explode()

func shake_and_explode():
	var boss_sprite = $BossSprite
	var textures = [
		preload("res://Textures/Mothership/mothership_2_dim(2).png"),
		preload("res://Textures/Mothership/mothership_4_bright(1).png"),
		preload("res://Textures/Mothership/mothership_3_medium(1).png")
	]
	var original_pos = boss_sprite.position
	var shake_timer = 0.0
	var texture_index = 0
	var texture_timer = 0.0
	
	while shake_timer < 3.0:
		boss_sprite.position = original_pos + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		texture_timer += 0.05
		if texture_timer >= 0.1:
			texture_timer = 0.0
			texture_index = (texture_index + 1) % textures.size()
			boss_sprite.texture = textures[texture_index]
		shake_timer += 0.05
		await get_tree().create_timer(0.05).timeout
	
	boss_sprite.position = original_pos
	boss_sprite.visible = false
	
	var screen = get_viewport_rect().size
	var explosion_rect = ColorRect.new()
	explosion_rect.color = Color(1, 0.5, 0, 1)
	explosion_rect.size = Vector2(10, 10)
	explosion_rect.position = boss_sprite.position - Vector2(5, 5)
	explosion_rect.z_index = 90
	add_child(explosion_rect)
	
	var exp_tween = create_tween()
	exp_tween.tween_property(explosion_rect, "size", screen, 0.3)
	exp_tween.parallel().tween_property(explosion_rect, "position", Vector2.ZERO, 0.3)
	await exp_tween.finished

# прямоугольник темнеет за 1 секунду
	#var fade_tween = create_tween()
	#fade_tween.tween_property(explosion_rect, "color:a", 0.0, 1.0)
	
	$BlackScreen.color = Color(0, 0, 0, 0)
	var fade_tween = create_tween()
	fade_tween.tween_property($BlackScreen, "color:a", 1.0, 1.0)
	
	await fade_tween.finished

	explosion_rect.queue_free()
	go_to_ending()
	
func go_to_ending():
	if Global.active_perks.has("ActiveCamo"):
		good_ending()
	else:
		bad_ending()

func bad_ending():
	$BackgroundContainer/Background.visible = false 
	$BackgroundContainer/Background2.visible = false # замени на имя своего фона
	$PlayerShip.visible = false
	# музыка появляется вместе с текстом
	var ending_music = $EndingMusic
	ending_music.stream = preload("res://Music/Last_Ship_Save.mp3")
	ending_music.volume_db = -80
	ending_music.play()
	
	$EndingText.modulate.a = 0.0
	$EndingText.visible = true
	$EndingText.text = "The Overseer fell.\nIts signal — silenced forever.\n\nThe drones stopped.\nAll of them. At once.\n\nPilot designation: unknown.\nSacrifice: recorded.\nEarth: saved.\n\nThey will not forget."
	
	var tween = create_tween()
	tween.tween_property($EndingText, "modulate:a", 1.0, 2.0)
	tween.parallel().tween_method(
		func(vol): ending_music.volume_db = vol, -80.0, -40.0, 2.0
	)
	await tween.finished
	
	await get_tree().create_timer(3.0).timeout
	
	# кнопка меню появляется постепенно
	$MenuButton.modulate.a = 0.0
	$MenuButton.visible = true
	var btn_tween = create_tween()
	btn_tween.tween_property($MenuButton, "modulate:a", 1.0, 1.0)

func good_ending():
	# запускаем фон
	$BackgroundContainer.visible = true
	$BackgroundContainer.scroll_speed = 300
	
	
	# показываем корабль
	$PlayerShip.visible = true
	$EngineFlame.visible = true
	$EngineFlame.play("default")
	
	# задержка 1 секунда
	await get_tree().create_timer(1.0).timeout
	
	# индикатор уворота
	Global.play_evade()
	var label = Label.new()
	label.text = "EVADE!"
	label.add_theme_font_size_override("font_size", 14)
	label.z_index = 90
	label.modulate = Color(0.3, 0.7, 1, 1)
	label.position = $PlayerShip.position + Vector2(-20, -40)
	add_child(label)
	var evade_tween = create_tween()
	evade_tween.tween_property(label, "position:y", label.position.y - 30, 0.5)
	evade_tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	evade_tween.tween_callback(label.queue_free)
	
	# оттемняемся
	var tween = create_tween()
	tween.tween_property($BlackScreen, "color:a", 0.0, 1.5)
	tween.parallel().tween_method(
		func(vol): Global.music_player.volume_db = vol, -80.0, -40.0, 1.5
	)
	Global.start_music()
	await tween.finished
	# остальной код...
	
	await get_tree().create_timer(2.0).timeout
	
	# текст появляется
	$EndingText.modulate.a = 0.0
	$EndingText.visible = true
	$EndingText.text = "The Overseer is gone.\nThe swarm — silent.\n\nEarth stands.\nYou made it back.\n\nMission complete.\nWelcome home, pilot."
	
	var text_tween = create_tween()
	text_tween.tween_property($EndingText, "modulate:a", 1.0, 1.0)
	await text_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	# кнопка меню
	$MenuButton.modulate.a = 0.0
	$MenuButton.visible = true
	var btn_tween = create_tween()
	btn_tween.tween_property($MenuButton, "modulate:a", 1.0, 1.0)
	
func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
