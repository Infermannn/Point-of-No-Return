extends Area2D

var hp = 1500
var speed = 200  # 2x basic
var reached_position = false
var stop_y = 0
var move_direction_x = 1
var move_direction_y = 1
var move_range_x = 150
var move_range_y = 100
var start_x = 0
var start_y = 0

var bullet_scene = preload("res://enemy_bullet.tscn")
var big_bullet_scene = preload("res://big_bullet.tscn")  # новая
var shoot_timer = 0
var shoot_interval = 1.33  # 1.5x basic

func _ready():
	connect("area_entered", _on_area_entered)
	stop_y = randf_range(50, get_viewport_rect().size.y * 0.5)

func _process(delta):
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
	get_parent().add_child(big_bullet)
	
	var angle = deg_to_rad(30)
	for a in [-angle, angle]:
		var rotated_dir = base_dir.rotated(a)
		var bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = rotated_dir
		bullet.speed = 800
		bullet.damage = 200
		get_parent().add_child(bullet)

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		hp -= area.damage if "damage" in area else 100
		area.queue_free()
		if hp <= 0:
			queue_free()
			get_tree().get_first_node_in_group("world").enemy_killed()
