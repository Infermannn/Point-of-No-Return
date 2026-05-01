extends Area2D

var hp = 50
var speed = 350  # 2.5x basic
var reached_position = false
var stop_y = 0
var normal_enemy = true

var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_timer = 0
var shoot_interval = 1.54  #30% basic

func _ready():
	connect("area_entered", _on_area_entered)
	stop_y = randf_range(50, get_viewport_rect().size.y * 0.5)

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
		bullet.speed = 500
		bullet.damage = 50
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
		die()
