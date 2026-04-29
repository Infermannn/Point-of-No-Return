extends Node2D

var enemy_scene = preload("res://enemy.tscn")
var drone_scene = preload("res://drone_mk_1.tscn")
var big_guy_scene = preload("res://big_guy.tscn")

var spawn_timer = 0
var enemies_killed = 0
var enemies_spawned = 0
var game_started = false
var wave_active = false
var current_wave = 0

var waves = [
	#1: 10 basic
	{"enemies": [{"scene": "basic", "count": 10}], "spawn_interval": 0.5, "total": 10},
	#2: 15 basic + 10 drone
	{"enemies": [{"scene": "basic", "count": 15}, {"scene": "drone", "count": 10}], "spawn_interval": 0.3, "total": 25},
	#3: 10 basic + 30 drone
	{"enemies": [{"scene": "basic", "count": 10}, {"scene": "drone", "count": 30}], "spawn_interval": 0.3, "total": 40},
	#4: 1 big guy
	{"enemies": [{"scene": "big", "count": 1}], "spawn_interval": 0.2, "total": 1},
	#5: 1 big guy + 25 drone
	{"enemies": [{"scene": "drone", "count": 5}, {"scene": "big", "count": 1}, {"scene": "drone", "count": 20}], "spawn_interval": 0.3, "total": 26},
]

var spawn_queue = []
var spawn_interval = 2.0

func _process(delta):
	if not game_started:
		return
	if not wave_active:
		return
	if spawn_queue.is_empty():
		return
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		spawn_next()

func spawn_next():
	if spawn_queue.is_empty():
		return
	var type = spawn_queue.pop_front()
	var enemy
	if type == "basic":
		enemy = enemy_scene.instantiate()
	elif type == "drone":
		enemy = drone_scene.instantiate()
	elif type == "big":
		enemy = big_guy_scene.instantiate()
	enemy.position.x = randf_range(100, 1820)
	enemy.position.y = -50
	add_child(enemy)
	enemies_spawned += 1

func build_queue(wave_data):
	spawn_queue = []
	for entry in wave_data["enemies"]:
		for i in entry["count"]:
			spawn_queue.append(entry["scene"])

func start_game():
	game_started = true
	start_wave(0)

func start_next_wave():
	current_wave += 1
	if current_wave >= waves.size():
		get_tree().change_scene_to_file("res://victory.tscn")
		return
	start_wave(current_wave)

func start_wave(index):
	var wave_data = waves[index]
	spawn_interval = wave_data["spawn_interval"]
	enemies_killed = 0
	enemies_spawned = 0
	build_queue(wave_data)
	wave_active = true
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Kills: 0/" + str(wave_data["total"])

func enemy_killed():
	enemies_killed += 1
	var wave_data = waves[current_wave]
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Kills: " + str(enemies_killed) + "/" + str(wave_data["total"])
	if enemies_killed >= wave_data["total"]:
		wave_active = false
		var player = get_tree().get_first_node_in_group("player")
		player.hp = player.max_hp
		for bullet in get_tree().get_nodes_in_group("player_bullet_node"):
			bullet.queue_free()
		for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
			bullet.queue_free()
		for enemy in get_tree().get_nodes_in_group("enemy"):
			enemy.queue_free()
		get_node("UpgradeScreen").showw()
		get_tree().paused = true
		get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
