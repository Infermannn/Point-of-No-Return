extends Area2D

var hp = 50000
var normal_enemy = false
var phase = 1  # 1, 2, 3 в зависимости от хп

# движение при входе
var entering = true
var target_y = 150.0
var enter_speed = 80.0

# дроны
var drone_scene = preload("res://drone_mk_1.tscn")
var drone_timer = 0.0
var drone_interval = 4.0

# пушки
var cannon_left: Node2D
var cannon_right: Node2D
#var laser_scene = preload("res://laser.tscn")  # создадим позже
var laser_timer = 0.0
var laser_interval = 3.0

# пули
var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_timer = 0.0
var shoot_interval = 2.0

func _ready():
	connect("area_entered", _on_area_entered)
	cannon_left = $CannonLeft
	cannon_right = $CannonRight
	$AnimatedSprite2D.play("default")
	
	# стартовая позиция сверху
	var screen = get_viewport_rect().size
	position = Vector2(screen.x / 2, -200)

func _process(delta):
	# фаза зависит от хп
	update_phase()
	
	# вход на сцену
	if entering:
		position.y += enter_speed * delta
		if position.y >= target_y:
			position.y = target_y
			entering = false
		return
	
	# поворот пушек к игроку
	rotate_cannons()
	
	# стрельба пулями
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0
		shoot_bullets()
	
	# лазеры
	laser_timer += delta
	if laser_timer >= laser_interval:
		laser_timer = 0
		fire_lasers()
	
	# дроны
	drone_timer += delta
	if drone_timer >= drone_interval:
		drone_timer = 0
		spawn_drones()

func update_phase():
	var hp_percent = float(hp) / 50000.0
	if hp_percent > 0.6:
		phase = 1
		shoot_interval = 2.0
		drone_interval = 4.0
		laser_interval = 3.0
	elif hp_percent > 0.3:
		phase = 2
		shoot_interval = 1.5
		drone_interval = 3.0
		laser_interval = 2.5
	else:
		phase = 3
		shoot_interval = 1.0
		drone_interval = 2.0
		laser_interval = 2.0

func rotate_cannons():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if cannon_left:
		cannon_left.look_at(player.global_position)
	if cannon_right:
		cannon_right.look_at(player.global_position)

func shoot_bullets():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	# стреляем с обеих пушек
	for cannon in [cannon_left, cannon_right]:
		if cannon == null:
			continue
		var bullet = bullet_scene.instantiate()
		bullet.position = cannon.global_position
		bullet.direction = (player.global_position - cannon.global_position).normalized()
		bullet.speed = 500 * Global.difficulty
		bullet.damage = 120 * Global.difficulty
		get_parent().add_child(bullet)
	
	# в фазе 3 дополнительные пули веером
	if phase == 3:
		var base_dir = (player.global_position - global_position).normalized()
		for a in [-30, -15, 15, 30]:
			var bullet = bullet_scene.instantiate()
			bullet.position = global_position
			bullet.direction = base_dir.rotated(deg_to_rad(a))
			bullet.speed = 400 * Global.difficulty
			bullet.damage = 100 * Global.difficulty
			get_parent().add_child(bullet)

func fire_lasers():
	pass  # добавим когда создадим лазер

func spawn_drones():
	var count = 2 if phase == 1 else (3 if phase == 2 else 4)
	for i in count:
		var drone = drone_scene.instantiate()
		drone.position = Vector2(randf_range(100, 1820), -50)  # сверху экрана
		drone.stop_y = randf_range(400, get_viewport_rect().size.y * 0.5)  # останавливается ниже босса
		drone.counts_as_kill = false
		get_parent().add_child(drone)

func die():
	# анимация смерти босса
	queue_free()
	get_tree().get_first_node_in_group("world").enemy_killed()

func _on_area_entered(area):
	if not is_instance_valid(area):
		return
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		modulate = Color(1, 0.2, 0.2, 1)
		await get_tree().create_timer(0.1).timeout
		if not is_instance_valid(self):
			return
		modulate = Color(1, 1, 1, 1)
		if hp <= 0:
			die()
		return  # добавь return здесь
	if not is_instance_valid(area):  # проверяем снова после await
		return
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(150 * Global.difficulty)
