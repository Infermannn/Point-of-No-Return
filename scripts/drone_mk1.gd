extends Area2D

var hp = 110
var speed = 350 
var reached_position = false
var stop_y = 0
var normal_enemy = true

var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_timer = 0
var shoot_interval = 1.8  
var counts_as_kill = true

var explosion_scene = preload("res://explosion.tscn")

func _ready():
	hp *= Global.difficulty
	connect("area_entered", _on_area_entered)
	if stop_y == 0:
		stop_y = randf_range(50, get_viewport_rect().size.y * 0.5)
	if Global.endless_mode:
		hp *= Global.endless_enemy_mult

func _process(delta):
	if not reached_position:
		position.y += speed * delta
		if position.y >= stop_y:
			reached_position = true
	
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0
		shoot()

func shoot():
	var directions = [
		Vector2(0, 1),                          
		Vector2(-0.5, 1).normalized(),          
		Vector2(0.5, 1).normalized()            
	]
	for dir in directions:
		var bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = dir
		bullet.speed = 450
		bullet.damage = 60
		bullet.damage *= Global.difficulty
		bullet.damage = 50 * Global.difficulty * (Global.endless_enemy_mult if Global.endless_mode else 1.0)
		get_parent().add_child(bullet)
		
		
func die():
	if Global.explosive_rounds:
		var explosion = explosion_scene.instantiate()
		explosion.damage = 100
		explosion.damage_multiplier = 1.0
		get_parent().add_child(explosion)
		explosion.global_position = global_position
	queue_free()
	if counts_as_kill:
		get_tree().get_first_node_in_group("world").enemy_killed()

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		hit_flash()
		if hp <= 0:
			die()
	if area.is_in_group("player"):
		die()
		
func hit_flash():
	modulate = Color(1, 0.2, 0.2, 1)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)
