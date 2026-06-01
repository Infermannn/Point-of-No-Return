extends Area2D

var speed = 350
var hp = 400
var max_hp = 400
var attack_speed = 1.0
var shoot_timer = 0.0
var attack_damage = 100
var bullet_speed = 750
var godmode = false
var armor = 0
var paused = false
var evasion = 0

var bullet_scene = preload("res://bullet.tscn")

var invincible = false

var controls_enabled = true

var blocker: ColorRect = null
#var blocker = get_tree().get_first_node_in_group("input_blocker")

var focus_timer = 0.0
var focus_active = false
var last_position = Vector2.ZERO

var shield_cooldown = 0.0
var shield_active = false
var shield_node: Area2D = null

var bar_max_width = 0.0

func _ready():
	var fill = get_tree().get_first_node_in_group("player_hp_fill")
	if fill:
		bar_max_width = fill.size.x
	if Global.bullet_shield:
		create_bullet_shield()
	if Global.active_perks.has("Shrinker"):
		scale = Vector2(0.75, 0.75)
		$CollisionShape2D.scale = Vector2(0.75, 0.75)
	else:
		scale = Vector2(1, 1)
	hp = Global.player_hp
	max_hp = Global.player_max_hp
	speed = Global.player_speed
	attack_speed = Global.player_attack_speed
	attack_damage = Global.player_attack_damage
	armor = Global.player_armor
	evasion = Global.player_evasion
	process_mode = Node.PROCESS_MODE_ALWAYS
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(update_hud)
	add_child(timer)
	var screen = get_viewport_rect().size
	position = screen / 2
	connect("area_entered", _on_area_entered)
	set_process(true)
	godmode = false
	var label = get_tree().get_first_node_in_group("godmode_label")
	if label:
		label.visible = false
	
func update_hud():
	var hp_label = get_tree().get_first_node_in_group("hp_label")
	var speed_label = get_tree().get_first_node_in_group("speed_label")
	var as_label = get_tree().get_first_node_in_group("attack_speed_label")
	var ad_label = get_tree().get_first_node_in_group("attack_damage_label")
	var armor_label = get_tree().get_first_node_in_group("armor_label")
	var bs_label = get_tree().get_first_node_in_group("bullet_speed_label")
	
	if hp_label:
		hp_label.text = "HP: " + str(hp) + "/" + str(max_hp)
	if speed_label:
		speed_label.text = "Speed: " + str(speed)
	if as_label:
		as_label.text = "Attack Speed: " + str(attack_speed)
	if ad_label:
		ad_label.text = "Damage: " + str(attack_damage)
	if armor_label:
		armor_label.text = "Armor: " + str(armor)
	if bs_label:
		bs_label.text = "Evasion: " + str(evasion) + "%"
	update_hp_bar()

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		take_damage(area.damage)
		area.queue_free()
	if area.is_in_group("enemy"):
		if not ("contact_damage" in area) or area.contact_damage:
			take_damage(100)

func _process(delta):
	if Global.bullet_shield:
		if not shield_active:
			shield_cooldown -= delta
			if shield_cooldown <= 0:
				create_bullet_shield()
	if Global.focus:
		if position == last_position:
			focus_timer += delta
			if focus_timer >= 2.0:
				focus_active = true
		else:
			focus_timer = 0.0
			focus_active = false
		last_position = position
	if Input.is_action_just_pressed("escape"):
		var quit_btn = get_tree().get_first_node_in_group("quit_button")
		var pause_label = get_tree().get_first_node_in_group("pause_label")
		var world = get_tree().get_first_node_in_group("world")
		var bg = world.get_node("BackgroundContainer") if world else null
		var input_blocker = get_tree().get_first_node_in_group("input_blocker")
		if quit_btn:
			if quit_btn.visible:
				quit_btn.visible = false
				if pause_label:
					pause_label.visible = false
				if input_blocker:
					input_blocker.visible = false
				get_tree().paused = false
				if bg:
					bg.process_mode = Node.PROCESS_MODE_ALWAYS
				Global.music_player.stream_paused = Global.muted
			else:
				quit_btn.visible = true
				if pause_label:
					pause_label.visible = true
				if input_blocker:
					input_blocker.visible = true
				get_tree().paused = true
				if bg:
					bg.process_mode = Node.PROCESS_MODE_DISABLED
				Global.music_player.stream_paused = true
		return
	
	if not controls_enabled:
		return
	
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("toggle_godmode"):
		godmode = not godmode
		var label = get_tree().get_first_node_in_group("godmode_label")
		if label:
			label.visible = godmode
		print("Godmode: ", godmode)
		
	#if Input.is_action_just_pressed("mute"):
		#Global.toggle_mute()
		
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_F):
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.queue_free()
		get_tree().get_first_node_in_group("world").force_end_wave()
	
	var direction = Vector2.ZERO
	shoot_timer -= delta
	
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot_timer = attack_speed
		var bullet = bullet_scene.instantiate()
		bullet.scale = Vector2(Global.bullet_scale, Global.bullet_scale)
		bullet.position = position
		bullet.damage = attack_damage
		bullet.speed = bullet_speed
		if focus_active:
			bullet.damage = attack_damage * 1.25
		else:
			bullet.damage = attack_damage
		get_parent().add_child(bullet)
		
		if Global.secondary_turrets:
			for angle in [-30, 30]:
				var side_bullet = bullet_scene.instantiate()
				side_bullet.position = position
				side_bullet.damage = attack_damage * 0.25
				side_bullet.speed = bullet_speed
				var dir = Vector2(0, -1).rotated(deg_to_rad(angle))
				side_bullet.direction = dir
				get_parent().add_child(side_bullet)
			
		if Global.hydra and randf() < 0.25:
			await get_tree().create_timer(0.05).timeout
			if not is_instance_valid(self):
				return
			var hydra_bullet = bullet_scene.instantiate()
			hydra_bullet.position = position
			hydra_bullet.damage = attack_damage * 0.5
			hydra_bullet.speed = bullet_speed
			get_parent().add_child(hydra_bullet)
		
	if Input.is_action_just_pressed("escape"):
		var blocker = get_tree().get_first_node_in_group("input_blocker")
		var quit_btn = get_tree().get_first_node_in_group("quit_button")
		var pause_label = get_tree().get_first_node_in_group("pause_label")
		var world = get_tree().get_first_node_in_group("world")
		if quit_btn:
			if quit_btn.visible:
				blocker.visible = true
				quit_btn.visible = false
				if pause_label:
					pause_label.visible = false
				get_tree().paused = false
				Global.music_player.stream_paused = Global.muted
			else:
				blocker.visible = false
				quit_btn.visible = true
				if pause_label:
					pause_label.visible = true
				get_tree().paused = true
				Global.music_player.stream_paused = true
		return
	
	if get_tree().paused:
		return
	
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	
	position += direction * speed * delta
	var screen = get_viewport_rect().size
	position.x = clamp(position.x, 80, 1920 - 75)
	position.y = clamp(position.y, 55, screen.y - 85)
	
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("cheat_endless"):
		get_tree().change_scene_to_file("res://victory.tscn")

	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("cheat_maxstats"):
		max_stats()
		
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("cheat_boss"):
		get_tree().get_first_node_in_group("world").start_boss_fight()
	
func take_damage(amount):
	if invincible or godmode:
		return
	if evasion > 0 and randi() % 100 < evasion:
		show_evade_indicator()
		return
	if Global.active_camo and randf() < 0.20:
		show_evade_indicator()
		return
	invincible = true
	var actual_damage = amount
	if Global.glass_cannon:
		actual_damage *= 2
	if Global.bait_them:
		actual_damage *= 2
	actual_damage = max(actual_damage - Global.damage_reduction, 1)
	if Global.last_stand and not Global.last_stand_used and float(hp) / max_hp <= 0.1:
		Global.last_stand_used = true
		for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
			bullet.queue_free()
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if enemy.get_script().resource_path.contains("repeerc"):
				enemy.die()
		invincible = true
		var old_speed = speed
		speed = 750
		await get_tree().create_timer(2.0).timeout
		if not is_instance_valid(self):
			return
		invincible = false
		speed = old_speed
		return
	hp -= actual_damage
	if hp <= 0:
		Global.stop_boss_music()
		death_animation()
		return
	var label = get_tree().get_first_node_in_group("lives_label")
	if label != null:
		label.text = "HP: " + str(hp) + "/" + str(max_hp)
		
	var blink_tween = create_tween()
	blink_tween.set_loops(5)
	blink_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	blink_tween.tween_property(self, "modulate:a", 1.0, 0.1)
		
	await get_tree().create_timer(1.0).timeout
	invincible = false
	update_hp_bar()
	
func max_stats():
	var upgrade_screen = get_tree().get_first_node_in_group("upgrade_screen")
	var caps = upgrade_screen.get_caps()
	attack_speed = caps["AttackSpeed"]
	attack_damage = caps["AttackDamage"] if caps["AttackDamage"] != INF else attack_damage
	evasion = caps["Evasion"]
	hp = caps["HP"] if caps["HP"] != INF else hp
	max_hp = caps["HP"] if caps["HP"] != INF else max_hp
	speed = caps["ShipSpeed"]
	armor = caps["StatusResist"] if caps["StatusResist"] != INF else armor
	Global.player_hp = hp
	Global.player_max_hp = max_hp
	Global.player_speed = speed
	Global.player_attack_speed = attack_speed
	Global.player_attack_damage = attack_damage
	Global.player_evasion = evasion
	Global.player_armor = armor
	print("Stats maxed!")
	
func show_evade_indicator():
	Global.play_evade()
	modulate = Color(0.3, 0.5, 1, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	var label = Label.new()
	label.text = "EVADE!"
	label.add_theme_font_size_override("font_size", 14)
	label.z_index = 90
	label.modulate = Color(0.3, 0.7, 1, 1)
	
	label.position = global_position + Vector2(-20, -40)
	get_tree().get_first_node_in_group("world").add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)
	
func death_animation():
	controls_enabled = false
	godmode = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Global.music_player.stop()
	
	var black = ColorRect.new()
	black.color = Color(0, 0, 0, 1)
	black.position = Vector2(0, 0)
	black.size = Vector2(1920, 1080)
	black.z_index = 50
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().get_first_node_in_group("world").add_child(black)
	
	z_index = 60
	
	var original_pos = position
	var shake_timer = 0.0
	while shake_timer < 1.0:
		position = original_pos + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		shake_timer += 0.05
		await get_tree().create_timer(0.05).timeout
	position = original_pos
	
	spawn_pieces(original_pos)
	visible = false
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://game_over.tscn")

func spawn_pieces(spawn_pos):
	var piece_textures = [
		preload("res://Textures/player/Playershippiecetop.png"),
		preload("res://Textures/player/Playershippieceright.png"),
		preload("res://Textures/player/Playershippiecebottom.png"),
	]
	
	for i in piece_textures.size():
		var piece = Sprite2D.new()
		piece.texture = piece_textures[i]
		piece.position = spawn_pos
		piece.scale = Vector2(0.15, 0.15)
		piece.z_index = 60
		get_parent().add_child(piece)
		
		var angle = (i * 120 + randf_range(-40, 40))
		var dir = Vector2(sin(deg_to_rad(angle)), -cos(deg_to_rad(angle)))
		var target = spawn_pos + dir * 1500
		
		var tween = get_tree().create_tween()
		tween.tween_property(piece, "position", target, 1.0)
		tween.parallel().tween_property(piece, "modulate:a", 0.0, 0.8)
		tween.parallel().tween_property(piece, "rotation", piece.rotation + randf_range(4.0, 7.0), 1.0)
		tween.tween_callback(piece.queue_free)
		
func create_bullet_shield():
	shield_node = Area2D.new()
	shield_node.collision_layer = 4
	shield_node.collision_mask = 2
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 80
	shape.shape = circle
	shield_node.add_child(shape)
	
	var line = Line2D.new()
	var points = 32
	for i in points + 1:
		var angle = i * TAU / points
		line.add_point(Vector2(cos(angle), sin(angle)) * 80)
	line.width = 3
	line.default_color = Color(0.3, 0.7, 1, 0.6)
	shield_node.add_child(line)
	
	shield_node.connect("area_entered", _on_shield_hit)
	add_child(shield_node)
	shield_active = true

func _on_shield_hit(area):
	if not shield_active:
		return
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
	shield_active = false
	shield_cooldown = 15.0
	if shield_node:
		shield_node.queue_free()
		shield_node = null
	
func update_hp_bar():
	var fill = get_tree().get_first_node_in_group("player_hp_fill")
	#print("fill: ", fill, " size: ", fill.size.x if fill else "null")
	#print("bar_max_width: ", bar_max_width)
	#print("hp percent: ", float(hp) / max_hp)
	var label = get_tree().get_first_node_in_group("player_hp_text")
	if fill:
		fill.size.x = bar_max_width * (float(hp) / max_hp)
	if label:
		label.text = str(hp) + "/" + str(max_hp)
