extends Node2D

var speed = 200
var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_timer = 0
var shoot_interval = 2.0

func _process(delta):
	position.y += speed * delta
	
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0
		shoot()
	
	if position.y > 750:
		queue_free()

func shoot():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(bullet)
	
func _ready():
	connect("area_entered", _on_area_entered)

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		queue_free()
		area.queue_free()
		get_tree().get_first_node_in_group("world").enemy_killed()
