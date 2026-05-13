extends Area2D

var hp = 2000
var speed = 600
var normal_enemy = true
var reached_position = false
var stop_y = 0
var move_direction_x = 1
var move_direction_y = 1
var move_range_x = 900
var move_range_y = 150
var start_x = 0
var start_y = 0

var bomb_scene = preload("res://bomb.tscn")
var bomb_timer = 0
var bomb_interval = 1.5

func _ready():
	connect("area_entered", _on_area_entered)
	stop_y = randf_range(50, get_viewport_rect().size.y * 0.3)
	hp *= Global.difficulty

func _process(delta):
	if not reached_position:
		position.y += speed * delta
		if position.y >= stop_y:
			reached_position = true
			start_x = position.x
			start_y = position.y
	else:
		position.x += move_direction_x * speed * delta
		position.y += move_direction_y * speed * 0.5 * delta
		
		var screen = get_viewport_rect().size
		if position.x >= screen.x - 50:
			move_direction_x = -1
		if position.x <= 50:
			move_direction_x = 1
		if position.y >= stop_y + move_range_y:
			move_direction_y = -1
		if position.y <= stop_y - move_range_y:
			move_direction_y = 1
	
	bomb_timer += delta
	if bomb_timer >= bomb_interval:
		bomb_timer = 0
		drop_bomb()

func drop_bomb():
	var bomb = bomb_scene.instantiate()
	bomb.position = global_position
	get_tree().get_first_node_in_group("world").add_child(bomb)

func die():
	queue_free()
	get_tree().get_first_node_in_group("world").enemy_killed()

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		if hp <= 0:
			die()
