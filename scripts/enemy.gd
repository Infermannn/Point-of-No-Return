extends Area2D

var speed = 250
var reached_position = false
var move_direction = 1
var move_range = 100
var hp = 110
var start_x = 0
var normal_enemy = true

var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_timer = 0
var shoot_interval = 2

func _ready():
	connect("area_entered", _on_area_entered)

func _process(delta):
	if not reached_position:
		position.y += speed * delta
		if position.y >= 300:
			reached_position = true
			start_x = position.x
	else:
		position.x += move_direction * speed * delta
		if position.x > start_x + move_range:
			move_direction = -1
		if position.x < start_x - move_range:
			move_direction = 1
	
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0
		shoot()

func shoot():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.damage = 90
	bullet.speed = 300
	get_parent().add_child(bullet)
	
func die():
	queue_free()
	get_tree().get_first_node_in_group("world").enemy_killed()
	print("enemy died, calling enemy_killed")
  

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		if hp <= 0:
			die()
	if area.is_in_group("player"):
		die()
