extends Node2D

var enemy_scene = preload("res://enemy.tscn")
var drone_scene = preload("res://drone_mk_1.tscn")
var big_guy_scene = preload("res://big_guy.tscn")
var bomber_scene = preload("res://bomber.tscn")
var repeerc_scene = preload("res://repeerc.tscn")

var spawn_timer = 0
var enemies_killed = 0
var enemies_spawned = 0
var game_started = false
var wave_active = false
var current_wave = Global.current_wave
var total_enemies_in_wave = 0
var total_kills = 0

var no_enemy_timer = 0
var no_enemy_timeout = 15.0

var max_enemies_on_screen = 6
var active_modifiers = []

var shake_amount = 0.0
var original_player_pos = Vector2.ZERO


var waves = [
	# 1 - tutorial
	{"enemies": [{"scene": "repeerc", "count": 1000}, {"scene": "drone", "count": 1}], 
	 "spawn_interval": 0.5, "max_on_screen": 1000, "modifiers": [{"type": "asteroids", "interval": 0.5}]},
	
	# 2 - drones
	{"enemies": [{"scene": "basic", "count": 7}, {"scene": "drone", "count": 5}], 
	 "spawn_interval": 1.0, "max_on_screen": 6, "modifiers": []},
	
	# 3 - more
	{"enemies": [{"scene": "drone", "count": 7}, {"scene": "basic", "count": 6}, {"scene": "drone", "count": 5}], 
	 "spawn_interval": 0.9, "max_on_screen": 7, "modifiers": []},
	
	# 4 - big guy
	{"enemies": [{"scene": "basic", "count": 3}, {"scene": "big", "count": 1}, {"scene": "drone", "count": 3}], 
	 "spawn_interval": 1, "max_on_screen": 7, "modifiers": []},
	
	# 5 - bomber
	{"enemies": [{"scene": "drone", "count": 5}, {"scene": "bomber", "count": 1}, {"scene": "drone", "count": 5}, {"scene": "basic", "count": 3}], 
	 "spawn_interval": 0.8, "max_on_screen": 8, "modifiers": []},
	
	# 6 - repeerc
	{"enemies": [{"scene": "basic", "count": 6}, {"scene": "drone", "count": 6}, {"scene": "repeerc", "count": 3}, {"scene": "basic", "count": 3}, {"scene": "drone", "count": 5}], 
	 "spawn_interval": 0.8, "max_on_screen": 8, "modifiers": []},
	
	# 7 - asteroids first time with pressure
	{"enemies": [{"scene": "drone", "count": 12}, {"scene": "basic", "count": 10}, {"scene": "drone", "count": 12}, {"scene": "repeerc", "count": 6}, {"scene": "basic", "count": 10}, {"scene": "drone", "count": 12}, {"scene": "repeerc", "count": 6}, {"scene": "basic", "count": 10}, {"scene": "drone", "count": 12}], 
 	"spawn_interval": 0.7, "max_on_screen": 9, "modifiers": [{"type": "asteroids", "interval": 3.0}]},
	
	# 8 - big guy in chaos
	{"enemies": [{"scene": "drone", "count": 8}, {"scene": "big", "count": 1}, {"scene": "repeerc", "count": 8}, {"scene": "drone", "count": 7}, {"scene": "basic", "count": 7}], 
	 "spawn_interval": 0.7, "max_on_screen": 9, "modifiers": []},
	
	# 9 - bomber later
	{"enemies": [{"scene": "basic", "count": 7}, {"scene": "drone", "count": 7}, {"scene": "bomber", "count": 1}, {"scene": "repeerc", "count": 8}, {"scene": "drone", "count": 9}, {"scene": "bomber", "count": 1}], 
	 "spawn_interval": 0.6, "max_on_screen": 10, "modifiers": []},
	
	# 10 - big wave with asteroids
	{"enemies": [{"scene": "drone", "count": 12}, {"scene": "repeerc", "count": 6}, {"scene": "basic", "count": 12}, {"scene": "drone", "count": 12}, {"scene": "repeerc", "count": 6}, {"scene": "basic", "count": 12}, {"scene": "drone", "count": 12}, {"scene": "repeerc", "count": 6}, {"scene": "basic", "count": 12}, {"scene": "drone", "count": 10}], 
 	"spawn_interval": 0.5, "max_on_screen": 11, "modifiers": [{"type": "asteroids", "interval": 2.5}]},

	# 11 - 2 big guy + support
	{"enemies": [{"scene": "drone", "count": 8}, {"scene": "big", "count": 1}, {"scene": "repeerc", "count": 4}, {"scene": "drone", "count": 8}, {"scene": "big", "count": 1}, {"scene": "basic", "count": 8}, {"scene": "repeerc", "count": 4}], 
	 "spawn_interval": 0.6, "max_on_screen": 11, "modifiers": []},
	
	# 12 - bomber + big guy + asteroids
	{"enemies": [{"scene": "drone", "count": 10}, {"scene": "bomber", "count": 1}, {"scene": "big", "count": 1}, {"scene": "drone", "count": 10}, {"scene": "repeerc", "count": 6}, {"scene": "drone", "count": 10}, {"scene": "bomber", "count": 1}, {"scene": "repeerc", "count": 6}, {"scene": "drone", "count": 10}, {"scene": "big", "count": 1}, {"scene": "bomber", "count": 1}, {"scene": "drone", "count": 10}, {"scene": "repeerc", "count": 6}], 
 	"spawn_interval": 0.5, "max_on_screen": 12, "modifiers": [{"type": "asteroids", "interval": 2.0}]},

	# 13 - chaos1
	{"enemies": [{"scene": "basic", "count": 10}, {"scene": "drone", "count": 8}, {"scene": "repeerc", "count": 15}, {"scene": "basic", "count": 9}, {"scene": "repeerc", "count": 25}, {"scene": "drone", "count": 9}], 
	 "spawn_interval": 0.4, "max_on_screen": 13, "modifiers": [{"type": "asteroids", "interval": 1.5}]},
	
	# 14 - two big guys two bombers
	{"enemies": [{"scene": "drone", "count": 10}, {"scene": "big", "count": 1}, {"scene": "bomber", "count": 1}, {"scene": "repeerc", "count": 6}, {"scene": "drone", "count": 10}, {"scene": "basic", "count": 10}, {"scene": "big", "count": 1}, {"scene": "drone", "count": 10}, {"scene": "bomber", "count": 1}, {"scene": "repeerc", "count": 6}, {"scene": "drone", "count": 10}, {"scene": "basic", "count": 10}, {"scene": "big", "count": 1}, {"scene": "bomber", "count": 1}], 
 	"spawn_interval": 0.5, "max_on_screen": 14, "modifiers": [{"type": "asteroids", "interval": 2.5}]},

	# 15 - FINAL WAVE
{"enemies": [
	{"scene": "drone", "count": 15}, {"scene": "big", "count": 1}, {"scene": "bomber", "count": 1},
	{"scene": "repeerc", "count": 8}, {"scene": "drone", "count": 15}, {"scene": "basic", "count": 12},
	{"scene": "big", "count": 1}, {"scene": "bomber", "count": 1}, {"scene": "repeerc", "count": 15},
	{"scene": "repeerc", "count": 8}, {"scene": "basic", "count": 12}, {"scene": "drone", "count": 15},
	{"scene": "big", "count": 1}, {"scene": "bomber", "count": 2}, {"scene": "repeerc", "count": 8},
	{"scene": "drone", "count": 15}, {"scene": "basic", "count": 12}, {"scene": "big", "count": 2},
	{"scene": "drone", "count": 15}, {"scene": "bomber", "count": 2}, {"scene": "repeerc", "count": 8},
	{"scene": "repeerc", "count": 12}, {"scene": "drone", "count": 15}, {"scene": "big", "count": 2},
	{"scene": "bomber", "count": 2}, {"scene": "repeerc", "count": 8}, {"scene": "drone", "count": 15}
], 
 "spawn_interval": 0.35, "max_on_screen": 20, "modifiers": [{"type": "asteroids", "interval": 1.5}]},
]

var spawn_queue = []
var spawn_interval = 2.0

var asteroid_scene = preload("res://asteroid.tscn")
var asteroid_timer = 0
var asteroid_interval = 0

var intro_active = true
var intro_state = "undimming"
var intro_timer = 0
var intro_enemies = []
var red_blink_speed = 0.0
var red_blink_timer = 0.0

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.visible = false
	$BackgroundContainer.visible = false
	
	# чёрный экран
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_index = 100
	add_child(fade)
	
	var tween = create_tween()
	tween.tween_interval(0.3)
	tween.tween_callback(func():
		if player:
			player.visible = true
		$BackgroundContainer.visible = true
	)
	tween.tween_property(fade, "color:a", 0.0, 1.0)
	tween.tween_callback(fade.queue_free)
	
	if not Global.tutorial_done:
		for label in ["hp_label", "speed_label", "attack_speed_label", "attack_damage_label", "armor_label", "bullet_speed_label", "kills_label", "wave_label", "difficulty_label"]:
			var node = get_tree().get_first_node_in_group(label)
			if node:
				node.visible = false
	if Global.tutorial_done:
		intro_active = false
		return
	if player:
		player.controls_enabled = false
		player.godmode = true
		player.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if intro_active:
		process_intro(delta)
		return
	if not game_started:
		return
	if not wave_active:
		return
	if spawn_queue.is_empty():
		var alive = get_tree().get_nodes_in_group("enemy").size()
		if alive <= 0:
			no_enemy_timer += delta
			if no_enemy_timer >= no_enemy_timeout:
				no_enemy_timer = 0
				check_wave_complete.call_deferred()
		else:
			no_enemy_timer = 0
	if asteroid_interval > 0:
		asteroid_timer += delta
		if asteroid_timer >= asteroid_interval:
			asteroid_timer = 0
			spawn_asteroid()
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		spawn_next()
		
func force_end_wave():
	spawn_queue = []
	wave_active = false
	var player = get_tree().get_first_node_in_group("player")
	player.hp = player.max_hp
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	start_upgrade_sequence()
	Global.set_music_volume(0.5)
	Global.music_player.stream_paused = Global.muted
	get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
		
func show_upgrades():
	get_node("UpgradeScreen/Dimmer").visible = true
	get_node("UpgradeScreen").showw()
	get_tree().paused = true
	get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS

func spawn_next():
	var alive = get_tree().get_nodes_in_group("enemy").size()
	if alive >= max_enemies_on_screen:
		return
	if spawn_queue.is_empty():
		return
	var type = spawn_queue.pop_front()
	var enemy
	if type == "basic":
		enemy = enemy_scene.instantiate()
	elif type == "drone":
		enemy = drone_scene.instantiate()
	elif type == "big":
		enemy = big_guy_scene.instantiate()
	elif type == "bomber":
		enemy = bomber_scene.instantiate()
	elif type == "repeerc":
		enemy = repeerc_scene.instantiate()
	enemy.position.x = randf_range(100, 1820)
	enemy.position.y = -50
	add_child(enemy)
	enemies_spawned += 1

func build_queue(wave_data):
	spawn_queue = []
	total_enemies_in_wave = 0
	for entry in wave_data["enemies"]:
		total_enemies_in_wave += entry["count"]
		for i in entry["count"]:
			spawn_queue.append(entry["scene"])

func start_game():
	if game_started:
		return
	game_started = true
	current_wave = Global.current_wave
	
	var bg = get_node("BackgroundContainer")
	while is_instance_valid(bg) and bg.scroll_speed > bg.base_speed + 10:
		if not is_instance_valid(self):
			return
		await get_tree().create_timer(0.1).timeout
	
	if not is_instance_valid(self):
		return
	
	var diff_label = get_tree().get_first_node_in_group("difficulty_label")
	if diff_label:
		var diff_text = "Normal"
		if Global.difficulty == 0.5:
			diff_text = "Easy"
		elif Global.difficulty == 1.5:
			diff_text = "Hard"
		diff_label.text = "Difficulty: " + diff_text
	
	if Global.endless_mode:
		Global.endless_wave += 1
		var wave_data = generate_endless_wave(Global.endless_wave)
		start_wave_from_data(wave_data)
		return
	
	start_wave(current_wave)

func start_next_wave():
	print("start_next_wave called, current_wave: ", current_wave)
	current_wave += 1
	Global.current_wave = current_wave
	
	if Global.endless_mode:
		Global.endless_wave += 1
		var wave_data = generate_endless_wave(Global.endless_wave)
		start_wave_from_data(wave_data)
		return
	
	if current_wave >= waves.size():
		get_tree().change_scene_to_file("res://victory.tscn")
		return
	start_wave(current_wave)

func enemy_killed():
	enemies_killed += 1
	total_kills += 1
	print("enemy_killed called! killed: ", enemies_killed, " total: ", total_enemies_in_wave)
	print("killed: ", enemies_killed, " total: ", total_enemies_in_wave)
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		var left = total_enemies_in_wave - enemies_killed
		label.text = "Enemies left: " + str(left) + "  Total kills: " + str(total_kills)
	check_wave_complete.call_deferred()
	
func add_enemy():
	total_enemies_in_wave += 1

func start_wave(index):
	no_enemy_timer = 0
	print("start_wave called with index: ", index)
	Global.current_wave = index
	var wave_data = waves[index]
	active_modifiers = wave_data.get("modifiers", [])
	max_enemies_on_screen = wave_data.get("max_on_screen", 10)
	max_enemies_on_screen = int(max_enemies_on_screen * Global.difficulty)
	asteroid_interval = 0 
	asteroid_timer = 0
	for modifier in active_modifiers:
		if modifier["type"] == "asteroids":
			asteroid_interval = modifier["interval"]
	spawn_interval = wave_data["spawn_interval"]
	enemies_killed = 0
	enemies_spawned = 0
	build_queue(wave_data)
	wave_active = true
	var wave_label = get_tree().get_first_node_in_group("wave_label")
	if wave_label:
		wave_label.text = "Wave: " + str(current_wave + 1) + "/" + str(waves.size())
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Enemies left: " + str(total_enemies_in_wave) + "  Total kills: " + str(total_kills)

func check_wave_complete():
	await get_tree().process_frame
	var alive = get_tree().get_nodes_in_group("enemy").size()
	print("check - alive: ", alive, " queue: ", spawn_queue.size(), " killed: ", enemies_killed, " total: ", total_enemies_in_wave)
	if alive <= 0 and spawn_queue.is_empty():
		wave_active = false
		var player = get_tree().get_first_node_in_group("player")
		player.hp = player.max_hp
		for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
			bullet.queue_free()
		start_upgrade_sequence()
		Global.set_music_volume(0.5)
		Global.music_player.stream_paused = Global.muted
		get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
		
func start_upgrade_sequence():
	var player = get_tree().get_first_node_in_group("player")
	var background = get_node("BackgroundContainer")
	
	player.controls_enabled = false
	
	var screen = get_viewport_rect().size
	var tween = create_tween()
	tween.tween_property(player, "position", Vector2(screen.x / 2, screen.y / 2), 1.5)
	
	background.speed_up()
	
	await get_tree().create_timer(2.0).timeout

	var upgrade_screen = get_node("UpgradeScreen")
	upgrade_screen.modulate = Color(1, 1, 1, 0) 
	upgrade_screen.showw()

	var tween2 = create_tween()
	tween2.tween_property(upgrade_screen, "modulate", Color(1, 1, 1, 1), 1.0)  
	
	get_node("UpgradeScreen").showw()
	Global.set_music_volume(0.5)
	Global.music_player.stream_paused = Global.muted
	get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	
func end_upgrade_sequence():
	var background = get_node("BackgroundContainer")
	background.slow_down()
	
	await get_tree().create_timer(2.0).timeout
	
	var player = get_tree().get_first_node_in_group("player")
	player.controls_enabled = true
	start_next_wave()
	
func spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	if randf() < 0.4:
		asteroid.is_small = true
	asteroid.position.x = randf_range(50, 1870)
	asteroid.position.y = -50
	add_child(asteroid)
	
func process_intro(delta):
	intro_timer += delta
	
	match intro_state:
		"undimming":
			$BackgroundContainer.scroll_speed = 0
			$BackgroundContainer.target_speed = 0
			var alpha = lerp(1.0, 0.5, min(intro_timer / 2.0, 1.0))
			$Dimmer2.color = Color(0, 0, 0, alpha)
			if intro_timer >= 2.0:
				intro_state = "enemies_coming"
				intro_timer = 0
				spawn_intro_enemies()
		
		"enemies_coming":
			var player = get_tree().get_first_node_in_group("player")
			if player:
				if original_player_pos == Vector2.ZERO:
					original_player_pos = player.position
				shake_amount = lerp(shake_amount, 3.0, delta * 0.5)  # нарастает
				player.position = original_player_pos + Vector2(
					randf_range(-shake_amount, shake_amount),
					randf_range(-shake_amount, shake_amount)
				)
			var closest_dist = INF
			for enemy in intro_enemies:
				if is_instance_valid(enemy):
					enemy.position.y += 80 * delta  
					if player:
						closest_dist = min(closest_dist, enemy.global_position.distance_to(player.global_position))
			
			
			if closest_dist < 800:
				red_blink_speed = lerp(red_blink_speed, 8.0, delta * 0.5)
			
			red_blink_timer += delta
			var blink_alpha = (sin(red_blink_timer * red_blink_speed) + 1) / 2
			$RedFlash.color = Color(1, 0, 0, blink_alpha * 0.35 * min(red_blink_speed / 8.0, 1.0))
			
			if intro_timer >= 5.0:
				intro_state = "flying_away"
				intro_timer = 0
		
		"flying_away":
			
			var alpha = lerp(0.5, 0.0, min(intro_timer / 1.0, 1.0))
			$Dimmer2.color = Color(0, 0, 0, alpha)
			
			
			red_blink_speed = lerp(red_blink_speed, 0.0, delta * 3)
			red_blink_timer += delta
			var blink_alpha = (sin(red_blink_timer * red_blink_speed) + 1) / 2
			$RedFlash.color = Color(1, 0, 0, blink_alpha * 0.35 * min(red_blink_speed / 8.0, 1.0))
			
			
			$BackgroundContainer.target_speed = 3000
			$BackgroundContainer.speed_change_rate = 3000
			
			
			var player = get_tree().get_first_node_in_group("player")
			if player and original_player_pos != Vector2.ZERO:
				player.position = original_player_pos  # возвращаем позицию
				original_player_pos = Vector2.ZERO
				shake_amount = 0.0
			for enemy in intro_enemies:
				if is_instance_valid(enemy):
					var side = 1 if enemy.global_position.x > 960 else -1
					enemy.position.x += side * 600 * delta
					enemy.position.y += 500 * delta
			
			if intro_timer >= 2.5:
				finish_intro()
		
func spawn_intro_enemies():
	var scenes = [enemy_scene, drone_scene, enemy_scene, drone_scene]
	for i in 200:
		var enemy = scenes[randi() % scenes.size()].instantiate()
		enemy.position = Vector2(randf_range(50, 1870), randf_range(-800, -50))
		if "shoot_interval" in enemy:
			enemy.shoot_interval = 99999
		if "bomb_interval" in enemy:
			enemy.bomb_interval = 99999
		if "drone_interval" in enemy:
			enemy.drone_interval = 99999
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(enemy)
		intro_enemies.append(enemy)

func finish_intro():
	for label in ["hp_label", "speed_label", "attack_speed_label", "attack_damage_label", "armor_label", "bullet_speed_label", "kills_label", "wave_label", "difficulty_label"]:
		var node = get_tree().get_first_node_in_group(label)
		if node:
			node.visible = true
	intro_active = false
	for enemy in intro_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	intro_enemies.clear()
	$RedFlash.color = Color(1, 0, 0, 0)
	$TutorialUI.visible = true
	$TutorialUI.show_message()
	Global.start_music()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.controls_enabled = true
		player.godmode = true

func generate_endless_wave(wave_index):
	var difficulty_mult = 1.0 + wave_index * 0.2
	Global.endless_enemy_mult = difficulty_mult
	
	var basic_count = randi_range(min(3 + wave_index, 30), min(15 + wave_index * 3, 80))
	var drone_count = randi_range(min(wave_index / 2, 15), min(8 + wave_index * 2, 60)) if wave_index >= 2 else 0
	var repeerc_count = randi_range(min(wave_index / 4, 8), min(3 + wave_index, 25)) if wave_index >= 3 else 0
	
	var big_chance = min(0.1 + wave_index * 0.05, 0.8)
	var bomber_chance = min(0.05 + wave_index * 0.04, 0.7)
	var big_count = 0
	var bomber_count = 0
	if wave_index >= 2:
		if randf() < big_chance:
			big_count = 1 + int(wave_index / 10)
		if randf() < bomber_chance:
			bomber_count = 1 + int(wave_index / 12)
	
	var spawn_int = max(0.2, 1.0 - wave_index * 0.08)
	
	var normal_cap = min(6 + wave_index, 20)
	var boss_cap = min(1 + wave_index / 5, 5)
	var max_screen = min(normal_cap + boss_cap, 25)
	
	var modifiers = []
	if randf() < min(0.3 + wave_index * 0.03, 0.8):
		modifiers.append({"type": "asteroids", "interval": max(0.5, 3.0 - wave_index * 0.1)})
	
	var enemies = []
	if basic_count > 0:
		enemies.append({"scene": "basic", "count": basic_count})
	if drone_count > 0:
		enemies.append({"scene": "drone", "count": drone_count})
	if repeerc_count > 0:
		enemies.append({"scene": "repeerc", "count": repeerc_count})
	if big_count > 0:
		enemies.append({"scene": "big", "count": big_count})
	if bomber_count > 0:
		enemies.append({"scene": "bomber", "count": bomber_count})
	
	return {"enemies": enemies, "spawn_interval": spawn_int, "max_on_screen": max_screen, "modifiers": modifiers}

func start_wave_from_data(wave_data):
	spawn_interval = wave_data["spawn_interval"]
	enemies_killed = 0
	enemies_spawned = 0
	max_enemies_on_screen = wave_data.get("max_on_screen", 10)
	max_enemies_on_screen = int(max_enemies_on_screen * Global.difficulty)
	active_modifiers = wave_data.get("modifiers", [])
	asteroid_interval = 0
	asteroid_timer = 0
	for modifier in active_modifiers:
		if modifier["type"] == "asteroids":
			asteroid_interval = modifier["interval"]
	build_queue(wave_data)
	wave_active = true
	var wave_label = get_tree().get_first_node_in_group("wave_label")
	if wave_label:
		wave_label.text = "Endless Wave: " + str(Global.endless_wave)
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Enemies left: " + str(total_enemies_in_wave) + "  Total kills: " + str(total_kills)

func _on_quit_button_pressed():
	Global.click_player.play()
	get_tree().paused = false
	Global.music_player.stream_paused = Global.muted
	get_tree().change_scene_to_file("res://menu.tscn")
