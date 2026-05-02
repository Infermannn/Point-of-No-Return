extends Node2D

var enemy_scene = preload("res://enemy.tscn")
var drone_scene = preload("res://drone_mk_1.tscn")
var big_guy_scene = preload("res://big_guy.tscn")
var bomber_scene = preload("res://bomber.tscn")

var spawn_timer = 0
var enemies_killed = 0
var enemies_spawned = 0
var game_started = false
var wave_active = false
var current_wave = Global.current_wave
var total_enemies_in_wave = 0
var total_kills = 0


var waves = [
	{"enemies": [{"scene": "basic", "count": 5}], "spawn_interval": 0.5}, 
	#1
	{"enemies": [{"scene": "basic", "count": 10}, {"scene": "drone", "count": 10}], "spawn_interval": 0.3},
	#2
	{"enemies": [{"scene": "basic", "count": 15}, {"scene": "drone", "count": 15}], "spawn_interval": 0.5},
	#3
	{"enemies": [{"scene": "drone", "count": 35}], "spawn_interval": 1.5},
	#4
	{"enemies": [{"scene": "big", "count": 1}], "spawn_interval": 0.5},
	#5
	{"enemies": [{"scene": "drone", "count": 50}], "spawn_interval": 0.8},
	#6: good luck
	{"enemies": [{"scene": "bomber", "count": 1}, {"scene": "drone", "count": 5}], "spawn_interval": 0.2},
	#7
	{"enemies": [{"scene": "basic", "count": 25}, {"scene": "drone", "count": 15}, {"scene": "bomber", "count": 1}], "spawn_interval": 0.4},
	#8
	{"enemies": [{"scene": "drone", "count": 40}, {"scene": "bomber", "count": 1}], "spawn_interval": 0.3},
	#9
	{"enemies": [{"scene": "basic", "count": 80}], "spawn_interval": 0.1},
	#10
	{"enemies": [{"scene": "big", "count": 1}, {"scene": "bomber", "count": 1}], "spawn_interval": 1},
	#11
	{"enemies": [{"scene": "bomber", "count": 3}], "spawn_interval": 0.1},
	#12
	{"enemies": [{"scene": "big", "count": 1}, {"scene": "basic", "count": 10}, {"scene": "drone", "count": 10}], "spawn_interval": 0.3},
	#13
	{"enemies": [{"scene": "big", "count": 1}, {"scene": "bomber", "count": 2}, {"scene": "drone", "count": 10}], "spawn_interval": 0.4},
	#14
	{"enemies": [{"scene": "big", "count": 2}, {"scene": "basic", "count": 15}, {"scene": "drone", "count": 10}, {"scene": "bomber", "count": 1}], "spawn_interval": 0.5},
	#15
	{"enemies": [{"scene": "big", "count": 3}, {"scene": "bomber", "count": 2}], "spawn_interval": 5},
	#16
	
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
	Global.music_player.stream_paused = Global.muted
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
	elif type == "bomber":
		enemy = bomber_scene.instantiate()
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
	Global.start_music()
	game_started = true
	current_wave = Global.current_wave
	start_wave(current_wave)

func start_next_wave():
	current_wave += 1
	Global.current_wave = current_wave
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
	Global.current_wave = index
	var wave_data = waves[index]
	spawn_interval = wave_data["spawn_interval"]
	enemies_killed = 0
	enemies_spawned = 0
	build_queue(wave_data)
	wave_active = true
	var wave_label = get_tree().get_first_node_in_group("wave_label")
	if wave_label:
		wave_label.text = "Wave: " + str(current_wave + 1) + "/" + str(waves.size())
	var label = get_tree().get_first_node_in_group("kills_label")
	if label:
		label.text = "Enemies left: " + str(total_enemies_in_wave) + "  Total kills: " + str(total_kills)

func check_wave_complete():
	await get_tree().process_frame
	var alive = get_tree().get_nodes_in_group("enemy").size()
	if alive <= 0 and spawn_queue.is_empty():
		wave_active = false
		var player = get_tree().get_first_node_in_group("player")
		player.hp = player.max_hp
		for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
			bullet.queue_free()
		get_node("UpgradeScreen").showw()
		get_tree().paused = true
		Global.music_player.stream_paused = Global.muted
		get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
