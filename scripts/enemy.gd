extends Area2D

var speed = 250
var reached_position = false
var move_direction = 1
var move_range = 100
var hp = 210
var start_x = 0
var normal_enemy = true

var bullet_scene = preload("res://enemy_bullet.tscn")
var shoot_timer = 0
var shoot_interval = 2

var anim_timer = 0
var anim_frame = 0
var texture1 = preload("res://Textures/enemies/BasicEnemyscaled.png")
var texture2 = preload("res://Textures/enemies/BasicEnemy2Scaled.png")

func _ready():
	connect("area_entered", _on_area_entered)
	hp *= Global.difficulty
	if Global.endless_mode:
		hp *= Global.endless_enemy_mult

func _process(delta):
	anim_timer += delta
	if anim_timer >= 1.0:
		anim_timer = 0
		anim_frame = 1 - anim_frame
	if anim_frame == 0:
		$Sprite2D.texture = texture1
	else:
		$Sprite2D.texture = texture2
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
	bullet.damage = 90 * Global.difficulty * (Global.endless_enemy_mult if Global.endless_mode else 1.0)
	bullet.modulate = Color(1, 0.5, 0.5, 1)
	get_parent().add_child(bullet)
	
func die():
	queue_free()
	get_tree().get_first_node_in_group("world").enemy_killed()
	print("enemy died, calling enemy_killed")
  

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
