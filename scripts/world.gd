extends Node2D

var enemy_scene = preload("res://enemy.tscn")
var spawn_timer = 0
var spawn_interval = 2.0
var enemies_killed = 0
var enemies_to_win = 5

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var screen = get_viewport_rect().size
	enemy.position.x = randf_range(50, screen.x - 50)
	enemy.position.y = -50
	add_child(enemy)

func enemy_killed():
	enemies_killed += 1
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Kills: " + str(enemies_killed) + "/5"
	if enemies_killed >= enemies_to_win:
		get_tree().change_scene_to_file("res://victory.tscn")
