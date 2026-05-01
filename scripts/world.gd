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
var total_enemies_in_wave = 0
var total_kills = 0

var waves = [
	#1: 10 basic
	{"enemies": [{"scene": "basic", "count": 10}], "spawn_interval": 0.5},
	#2: 15 basic + 10 drone
	{"enemies": [{"scene": "basic", "count": 20}, {"scene": "drone", "count": 5}], "spawn_interval": 0.45},
	#3: 10 basic + 30 drone
	{"enemies": [{"scene": "basic", "count": 25}, {"scene": "drone", "count": 15}], "spawn_interval": 0.4},
	#4: 1 big guy
	{"enemies": [{"scene": "drone", "count": 50}], "spawn_interval": 0.1},
	#5: 1 big guy + 25 drone
	{"enemies": [{"scene": "big", "count": 1}, {"scene": "drone", "count": 5}], "spawn_interval": 0.1},
	#6: good luck
	{"enemies": [{"scene": "big", "count": 5}], "spawn_interval": 0.1},
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
		
func force_end_wave():
	spawn_queue = []
	wave_active = false
	var player = get_tree().get_first_node_in_group("player")
	player.hp = player.max_hp
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()
	get_node("UpgradeScreen").showw()
	get_tree().paused = true
	get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
		
func show_upgrades():
	get_node("UpgradeScreen/Dimmer").visible = true
	get_node("UpgradeScreen").showw()
	get_tree().paused = true
	get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS

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
	total_enemies_in_wave = 0
	for entry in wave_data["enemies"]:
		total_enemies_in_wave += entry["count"]
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

func enemy_killed():
	enemies_killed += 1
	total_kills += 1
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		var left = total_enemies_in_wave - enemies_killed
		label.text = "Enemies left: " + str(left) + "  Total kills: " + str(total_kills)
	check_wave_complete.call_deferred()
	
func add_enemy():
	total_enemies_in_wave += 1

func start_wave(index):
	var wave_data = waves[index]
	spawn_interval = wave_data["spawn_interval"]
	enemies_killed = 0
	enemies_spawned = 0
	build_queue(wave_data)
	wave_active = true
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Enemies left: " + str(total_enemies_in_wave) + "  Total kills: " + str(total_kills)

func check_wave_complete():
	await get_tree().process_frame  # ждём один кадр
	var alive = get_tree().get_nodes_in_group("enemy").size()
	print("check - alive: ", alive, " queue: ", spawn_queue.size())
	if alive <= 0 and spawn_queue.is_empty():
		wave_active = false
		var player = get_tree().get_first_node_in_group("player")
		player.hp = player.max_hp
		for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
			bullet.queue_free()
		get_node("UpgradeScreen").showw()
		get_tree().paused = true
		get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
