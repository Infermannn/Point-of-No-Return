extends Area2D

var speed = 350
var hp = 400
var max_hp = 400
var attack_speed = 0.75
var shoot_timer = 0.0
var attack_damage = 100
var bullet_speed = 500
var godmode = false
var armor = 0
var paused = false

var bullet_scene = preload("res://bullet.tscn")



var invincible = false

func _ready():
	hp = Global.player_hp
	max_hp = Global.player_max_hp
	speed = Global.player_speed
	attack_speed = Global.player_attack_speed
	attack_damage = Global.player_attack_damage
	bullet_speed = Global.player_bullet_speed
	armor = Global.player_armor
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
		bs_label.text = "Bullet Speed: " + str(bullet_speed)

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		take_damage(area.damage)
		area.queue_free()
	if area.is_in_group("enemy"):
		take_damage(100)

func _process(delta):
	
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("toggle_godmode"):
		godmode = not godmode
		var label = get_tree().get_first_node_in_group("godmode_label")
		if label:
			label.visible = godmode
		print("Godmode: ", godmode)
		
	if Input.is_action_just_pressed("mute"):
		Global.toggle_mute()
		
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_C):
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.queue_free()
		get_tree().get_first_node_in_group("world").force_end_wave()
		
	if Input.is_action_just_pressed("pause"):
		var upgrade_screen = get_tree().get_first_node_in_group("upgrade_screen")
		if upgrade_screen and upgrade_screen.visible:
			return 
		paused = not paused
		get_tree().paused = paused
		Global.music_player.stream_paused = paused
		var label = get_tree().get_first_node_in_group("pause_label")
		if label:
			label.visible = paused
	
	var direction = Vector2.ZERO
	shoot_timer -= delta
	
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot_timer = attack_speed
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.damage = attack_damage
		bullet.speed = bullet_speed
		get_parent().add_child(bullet)
		
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://menu.tscn")
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
	
func take_damage(amount):
	if invincible or godmode:
		return
	invincible = true
	var actual_damage = max(amount - armor, 1)
	hp -= actual_damage
	if hp <= 0:
		get_tree().change_scene_to_file("res://game_over.tscn")
		return
	var label = get_tree().get_first_node_in_group("lives_label")
	if label != null:
		label.text = "HP: " + str(hp) + "/" + str(max_hp)
	await get_tree().create_timer(1.0).timeout
	invincible = false


	
	
	
	
	
	
