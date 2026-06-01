extends Area2D

var hp = 100000
var max_hp = 0
var normal_enemy = false
var phase = 1

var entering = true
var target_y = 150.0
var enter_speed = 40.0

var drone_scene = preload("res://drone_mk_1.tscn")
var drone_interval = 4.0

var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_interval = 2.0

var laser_active = false
var boss_fight_started = false

var laser_left: Line2D
var laser_right: Line2D
var warning_left: Line2D
var warning_right: Line2D

var cannon_idle_texture = preload("res://Textures/Mothership/LaserCannonIdle.png")
var cannon_fire_texture = preload("res://Textures/Mothership/LaserCannonActive.png")

var cannons_frozen = false

var glow_left: Line2D
var glow_right: Line2D
var mid_left: Line2D
var mid_right: Line2D

var phase1_texture = preload("res://Textures/Mothership/mothership_2_dim(2).png")
var phase2_texture = preload("res://Textures/Mothership/mothership_4_bright(1).png")
var phase3_texture = preload("res://Textures/Mothership/mothership_3_medium(1).png")

var hp_bar_timer = 0.0
var hp_bar_visible = false

var attack_timer = 0.0
var attack_interval = 5.0 
var current_attack = ""

var repeerc_scene = preload("res://repeerc.tscn")

var five_shot_active = false

var bomber_scene = preload("res://bomb.tscn")
var bomb_timer = 0.0
var bomb_interval = 2.0

var is_dying = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	max_hp = hp
	connect("area_entered", _on_area_entered)
	$AnimatedSprite2D.play("idle")
	
	var screen = get_viewport_rect().size
	position = Vector2(screen.x / 2, -300)
	
	$CannonLeft.rotation = deg_to_rad(180)
	$CannonRight.rotation = deg_to_rad(0)
	
	create_lasers()

func create_lasers():
	warning_left = Line2D.new()
	warning_left.width = 8
	warning_left.default_color = Color(1, 0, 0, 0.5)
	warning_left.visible = false
	add_child(warning_left)
	
	warning_right = Line2D.new()
	warning_right.width = 8
	warning_right.default_color = Color(1, 0, 0, 0.5)
	warning_right.visible = false
	add_child(warning_right)
	
	glow_left = Line2D.new()
	glow_left.width = 64
	glow_left.default_color = Color(1, 0, 0, 0.15)
	glow_left.visible = false
	add_child(glow_left)

	mid_left = Line2D.new()
	mid_left.width = 32
	mid_left.default_color = Color(1, 0.2, 0, 0.5)
	mid_left.visible = false
	add_child(mid_left)

	laser_left = Line2D.new()
	laser_left.width = 8
	laser_left.default_color = Color(1, 0.1, 0, 1.0)
	laser_left.visible = false
	add_child(laser_left)
	
	glow_right = Line2D.new()
	glow_right.width = 64
	glow_right.default_color = Color(1, 0, 0, 0.15)
	glow_right.visible = false
	add_child(glow_right)

	mid_right = Line2D.new()
	mid_right.width = 32
	mid_right.default_color = Color(1, 0.2, 0, 0.5)
	mid_right.visible = false
	add_child(mid_right)

	laser_right = Line2D.new()
	laser_right.width = 8
	laser_right.default_color = Color(1, 0.1, 0, 1.0)
	laser_right.visible = false
	add_child(laser_right)

func update_laser_positions():
	var muzzle_l = $CannonLeft/MuzzlePoint.global_position
	var muzzle_r = $CannonRight/MuzzlePoint.global_position
	
	var dir_l = Vector2(cos($CannonLeft.global_rotation), sin($CannonLeft.global_rotation))
	var dir_r = Vector2(cos($CannonRight.global_rotation), sin($CannonRight.global_rotation))
	
	var end_l = muzzle_l + dir_l * 2000
	var end_r = muzzle_r + dir_r * 2000
	
	for line in [warning_left, glow_left, mid_left, laser_left]:
		if line:
			line.clear_points()
			line.add_point(to_local(muzzle_l))
			line.add_point(to_local(end_l))
	
	for line in [warning_right, glow_right, mid_right, laser_right]:
		if line:
			line.clear_points()
			line.add_point(to_local(muzzle_r))
			line.add_point(to_local(end_r))

func show_lasers(on):
	if on:
		update_laser_positions()
	laser_left.visible = on
	laser_right.visible = on
	glow_left.visible = on
	glow_right.visible = on
	mid_left.visible = on
	mid_right.visible = on

func _process(delta):
	update_phase()
	
	if entering:
		position.y += enter_speed * delta
		if position.y >= target_y:
			position.y = target_y
			entering = false
			start_boss_sequence()
		return
	
	if not boss_fight_started:
		return
		
	bomb_timer += delta
	if bomb_timer >= bomb_interval:
		bomb_timer = 0
		spawn_bombs()
	
	follow_player(delta)
	
	if laser_active:
		update_laser_positions()
	
	attack_timer += delta
	if attack_timer >= attack_interval:
		attack_timer = 0
		choose_attack()
	else:
		if int(attack_timer) != int(attack_timer - delta):
			print("next attack in: ", int(attack_interval - attack_timer), " sec")
	
	if hp_bar_visible:
		hp_bar_timer -= delta
		if hp_bar_timer <= 0:
			var bar = get_tree().get_first_node_in_group("boss_hp_bar")
			if bar:
				bar.visible = false
			hp_bar_visible = false

func follow_player(delta):
	if cannons_frozen:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var dir_l = player.global_position - $CannonLeft.global_position
	var dir_r = player.global_position - $CannonRight.global_position
	var target_l = atan2(dir_l.y, dir_l.x)
	var target_r = atan2(dir_r.y, dir_r.x)
	$CannonLeft.rotation = lerp_angle($CannonLeft.rotation, target_l, delta * 2.0)
	$CannonRight.rotation = lerp_angle($CannonRight.rotation, target_r, delta * 2.0)

func start_boss_sequence():
	await get_tree().create_timer(1.0).timeout
	
	var screen = get_viewport_rect().size
	var center = Vector2(screen.x / 2, screen.y / 2)
	var dir_l = center - $CannonLeft.global_position
	var dir_r = center - $CannonRight.global_position
	
	var tween = create_tween()
	tween.tween_property($CannonLeft, "rotation", atan2(dir_l.y, dir_l.x), 1.0)
	tween.parallel().tween_property($CannonRight, "rotation", atan2(dir_r.y, dir_r.x), 1.0)
	await tween.finished
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.controls_enabled = true
	
	await charged_shot()
	
	if player and is_instance_valid(player):
		player.shoot_timer = -99 
		
	if player and is_instance_valid(player):
		player.shoot_timer = -99
		Global.start_boss_music()
	
	boss_fight_started = true

func charged_shot():
	laser_active = true
	cannons_frozen = true
	laser_active = true
	
	var frozen_rot_l = $CannonLeft.rotation
	var frozen_rot_r = $CannonRight.rotation
	
	$CannonLeft/Sprite2D.texture = cannon_fire_texture
	$CannonRight/Sprite2D.texture = cannon_fire_texture
	
	update_laser_positions()
	for i in 2:
		warning_left.visible = true
		warning_right.visible = true
		await get_tree().create_timer(0.25).timeout
		warning_left.visible = false
		warning_right.visible = false
		await get_tree().create_timer(0.25).timeout
	
	if not is_instance_valid(self):
		return
	
	show_lasers(true)
	warning_left.visible = false
	warning_right.visible = false
	
	var duration = 2.0 + (phase - 1) * 1.5
	duration = min(duration, 5.0)
	
	var elapsed = 0.0
	while elapsed < duration:
		if not is_instance_valid(self):
			return
		update_laser_positions()
		damage_in_laser()
		await get_tree().create_timer(1.0).timeout
		elapsed += 1.0
	
	if not is_instance_valid(self):
		return
	
	show_lasers(false)
	
	$CannonLeft/Sprite2D.texture = cannon_idle_texture
	$CannonRight/Sprite2D.texture = cannon_idle_texture
	
	await get_tree().create_timer(0.5).timeout
	cannons_frozen = false
	laser_active = false

func damage_in_laser():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var laser_width = 32
	
	for cannon in [$CannonLeft, $CannonRight]:
		var muzzle = cannon.get_node("MuzzlePoint").global_position
		var dir = Vector2(cos(cannon.global_rotation), sin(cannon.global_rotation))
		var to_player = player.global_position - muzzle
		var cross = abs(dir.x * to_player.y - dir.y * to_player.x)
		var dot = dir.dot(to_player)
		if cross < laser_width and dot > 0:
			player.take_damage(500)

func update_phase():
	var hp_percent = float(hp) / max_hp
	var old_phase = phase
	if hp_percent > 0.6:
		phase = 1
		attack_interval = 4.0
	elif hp_percent > 0.3:
		phase = 2
		attack_interval = 3
	else:
		phase = 3
		attack_interval = 2
	
	if phase != old_phase:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.hp = player.max_hp
			player.update_hp_bar()
		match phase:
			1: $AnimatedSprite2D.play("phase1")
			2: $AnimatedSprite2D.play("phase2")
			3: $AnimatedSprite2D.play("phase3")

func spawn_drones_attack():
	var count = 4 if phase == 1 else (4 if phase == 2 else 4)
	for i in count:
		var drone = drone_scene.instantiate()
		drone.position = Vector2(randf_range(100, 1820), -50)
		drone.stop_y = randf_range(400, get_viewport_rect().size.y * 0.6)
		drone.counts_as_kill = false
		get_parent().add_child(drone)

func die():
	Global.stop_boss_music()
	get_tree().change_scene_to_file("res://victory.tscn")
	

func _on_area_entered(area):
	if not is_instance_valid(area):
		return
	if area.is_in_group("player_bullet"):
		if is_dying:
			return
		hp -= area.damage
		area.queue_free()
		update_hp_bar()
		modulate = Color(1, 0.2, 0.2, 1)
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(self):
			return
		modulate = Color(1, 1, 1, 1)
		if hp <= 0 and not is_dying:
			is_dying = true
			die()
		return
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(150 * Global.difficulty)
			
func update_hp_bar():
	#print("update_hp_bar called")
	var bar = get_tree().get_first_node_in_group("boss_hp_bar")
	#print("bar: ", bar)
	if not bar:
		return
	
	var fill = bar.get_node("Fill")
	var percent = float(hp) / max_hp
	fill.size.x = 752 * percent
	
	match phase:
		1: fill.color = Color(0.8, 0.1, 0.1)
		2: fill.color = Color(0.9, 0.4, 0.0)
		3: fill.color = Color(1.0, 0.8, 0.0)
	
	bar.visible = true
	hp_bar_visible = true
	hp_bar_timer = 3.0
	
func choose_attack():
	var attacks = ["spawn_repeercs", "shoot_wave_attack"]
	
	if not five_shot_active:
		attacks.append("five_shot_attack")
	
	var drone_count = 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.normal_enemy == false:
			drone_count += 1
	if drone_count < 5:
		attacks.append("spawn_drones_attack")
	
	if not laser_active:
		attacks.append("charged_shot")
	
	if attacks.is_empty():
		return
	
	var chosen = attacks[randi() % attacks.size()]
	print("attack chosen: ", chosen)
	match chosen:
		"charged_shot":
			charged_shot()
		"spawn_drones_attack":
			spawn_drones_attack()
		"spawn_repeercs":
			spawn_repeercs()
		"shoot_wave_attack":
			shoot_wave_attack()
		"five_shot_attack":
			five_shot_attack()
		
func spawn_repeercs():
	for i in 2:
		var repeerc = repeerc_scene.instantiate()
		repeerc.position = Vector2(randf_range(100, 1820), -50)
		repeerc.counts_as_kill = false
		get_parent().add_child(repeerc)
		
func shoot_wave_attack():
	for wave in 12:
		if not is_instance_valid(self):
			return
		
		var point = $ShootPointLeft.global_position if wave % 2 == 0 else $ShootPointRight.global_position
		
		var start_angle = 0 - 67.5
		for i in 6:
			var angle = start_angle + i * (135.0 / 5.0)
			var dir = Vector2(sin(deg_to_rad(angle)), cos(deg_to_rad(angle)))
			var bullet = bullet_scene.instantiate()
			bullet.position = point
			bullet.direction = dir
			bullet.speed = 250
			bullet.damage = 150 * Global.difficulty
			bullet.scale = Vector2(0.1, 0.1)
			bullet.modulate = Color(1, 0, 0, 1)
			get_parent().add_child(bullet)
		
		await get_tree().create_timer(0.5).timeout
		
func five_shot_attack():
	if five_shot_active:
		return
	five_shot_active = true
	var shot_points = [$ShotPoint1, $ShotPoint2, $ShotPoint3, $ShotPoint4, $ShotPoint5]
	
	for point in shot_points:
		if not is_instance_valid(self):
			return
		var bomb = bomber_scene.instantiate()
		bomb.global_position = point.global_position
		get_parent().add_child(bomb)
		await get_tree().create_timer(0.25).timeout
	five_shot_active = false
	
func spawn_bombs():
	for point in [$BombPointLeft, $BombPointRight]:
		var bomb = bomber_scene.instantiate()
		bomb.global_position = point.global_position
		get_parent().add_child(bomb)
