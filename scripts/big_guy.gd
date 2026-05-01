extends Area2D

var hp = 5000
var speed = 250
var reached_position = false
var stop_y = 0
var move_direction_x = 1
var move_direction_y = 1
var move_range_x = 150
var move_range_y = 100
var start_x = 0
var start_y = 0
var normal_enemy = false
var drone_scene = preload("res://drone_mk_1.tscn")
var drone_timer = 0
var drone_interval = 5.0

var bullet_scene = preload("res://enemy_bullet.tscn")
var big_bullet_scene = preload("res://big_bullet.tscn")  # новая
var shoot_timer = 0
var shoot_interval = 1.33  # 1.5x basic

func _ready():
	connect("area_entered", _on_area_entered)
	stop_y = randf_range(50, get_viewport_rect().size.y * 0.5)
	
func spawn_drone():
	var drone = drone_scene.instantiate()
	drone.position = global_position
	get_parent().add_child(drone)
	get_tree().get_first_node_in_group("world").add_enemy()

func _process(delta):
	drone_timer += delta
	if drone_timer >= drone_interval:
		drone_timer = 0
		spawn_drone()
	if not reached_position:
		position.y += speed * delta
		if position.y >= stop_y:
			reached_position = true
			start_x = position.x
			start_y = position.y
	else:
		position.x += move_direction_x * speed * delta
		position.y += move_direction_y * speed * 0.67 * delta 
		
		if position.x > start_x + move_range_x:
			move_direction_x = -1
		if position.x < start_x - move_range_x:
			move_direction_x = 1
		if position.y > start_y + move_range_y:
			move_direction_y = -1
		if position.y < start_y - move_range_y:
			move_direction_y = 1
	
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0
		shoot()

func shoot():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var base_dir = (player.global_position - global_position).normalized()
	
	var big_bullet = big_bullet_scene.instantiate() 
	big_bullet.position = global_position
	big_bullet.direction = base_dir
	big_bullet.damage = 250
	big_bullet.speed = 1000
	get_parent().add_child(big_bullet)
	
	var angle = deg_to_rad(15)
	for a in [-angle, angle]:
		var rotated_dir = base_dir.rotated(a)
		var bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = rotated_dir
		bullet.speed = 800
		bullet.damage = 150
		get_parent().add_child(bullet)
		
func die():
	queue_free()
	get_tree().get_first_node_in_group("world").enemy_killed()

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		if hp <= 0:
			die()
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(100)  # игрок получает урон
		# big guy не получает урона и не умирает
