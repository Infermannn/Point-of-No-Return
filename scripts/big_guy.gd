extends Area2D

var hp = 3500
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
var drone_interval = 7.5

var bullet_scene = preload("res://enemy_bullet.tscn")
var big_bullet_scene = preload("res://big_bullet.tscn")
var shoot_timer = 0
var shoot_interval = 1.4  

var anim_timer = 0
var anim_frame = 0
var texture1 = preload("res://big_guyscaled.png")
var texture2 = preload("res://big_guy2scaled.png")

func _ready():
	connect("area_entered", _on_area_entered)
	stop_y = randf_range(50, get_viewport_rect().size.y * 0.3)
	hp *= Global.difficulty
	if Global.endless_mode:
		hp *= Global.endless_enemy_mult
	
func spawn_drone():
	var drone = drone_scene.instantiate()
	var screen = get_viewport_rect().size
	drone.position.x = clamp(global_position.x, 150, screen.x - 150)
	drone.position.y = clamp(global_position.y, 150, screen.y * 0.5)
	drone.counts_as_kill = false
	get_parent().add_child(drone)

func _process(delta):
	anim_timer += delta
	if anim_timer >= 1.0:
		anim_timer = 0
		anim_frame = 1 - anim_frame
	if anim_frame == 0:
		$Sprite2D.texture = texture1
	else:
		$Sprite2D.texture = texture2
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
	big_bullet.damage = 150
	big_bullet.speed = 750
	big_bullet.damage *= Global.difficulty
	big_bullet.damage = 150 * Global.difficulty * (Global.endless_enemy_mult if Global.endless_mode else 1.0)
	get_parent().add_child(big_bullet)
	
	var angle = deg_to_rad(15)
	for a in [-angle, angle]:
		var rotated_dir = base_dir.rotated(a)
		var bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = rotated_dir
		bullet.speed = 600
		bullet.damage = 125
		bullet.damage *= Global.difficulty
		bullet.modulate = Color(1, 0.3, 0, 1)
		bullet.damage = 125 * Global.difficulty * (Global.endless_enemy_mult if Global.endless_mode else 1.0)
		get_parent().add_child(bullet)
		
func die():
	queue_free()
	get_tree().get_first_node_in_group("world").enemy_killed()

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		hit_flash()
		if hp <= 0:
			die()
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(100)  

func hit_flash():
	modulate = Color(1, 0.2, 0.2, 1)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)
