extends Node


var bullet_damage = 1
var evasion = 0
var max_lives = 3
var current_level = 1
var current_wave = 0

var godmode = false

var tutorial_done = false

var player_hp = 300
var player_max_hp = 300
var player_speed = 350
var player_attack_speed = 1.0
var player_attack_damage = 100
var player_evasion = 0
var player_armor = 0

var music_player: AudioStreamPlayer
var tracks = []
var current_track = 0
var muted = false
var difficulty = 1.0  # 0.5 = easy, 1.0 = normal, 1.5 = hard

var endless_mode = false
var endless_wave = 0
var endless_enemy_mult = 1.0

var menu_music_player: AudioStreamPlayer
var menu_track = preload("res://Music/Starship_Idle.mp3")

var click_player: AudioStreamPlayer

var boss_music_player: AudioStreamPlayer
var boss_tracks = []
var boss_current_track = 0

var last_reroll_perk = ""

func _ready():
	click_player = AudioStreamPlayer.new()
	click_player.stream = preload("res://Sounds/button-click.mp3")
	click_player.volume_db = -40
	add_child(click_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -40
	add_child(music_player)
	music_player.finished.connect(_on_track_finished)
	tracks = [
		preload("res://Music/Pixel_Comet_Run.mp3"),
		preload("res://Music/Pixel_Starfire2.mp3"),
		preload("res://Music/Pixel_Starfire.mp3")
	]
	play_next_track()
	
	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.volume_db = -40
	add_child(menu_music_player)
	menu_music_player.stream = menu_track
	
	boss_music_player = AudioStreamPlayer.new()
	boss_music_player.volume_db = -40
	add_child(boss_music_player)
	boss_music_player.finished.connect(_on_boss_track_finished)
	boss_tracks = [
		preload("res://Music/Nebula_Overlord1.mp3"),
		preload("res://Music/Nebula_Overlord2.mp3")
	]
	
func start_music():
	if music_player.playing:
		return
	current_track = 0
	play_next_track()

func stop_music():
	music_player.stop()

func play_next_track():
	if tracks.is_empty():
		return
	music_player.stream = tracks[current_track]
	music_player.stream_paused = false
	music_player.play()
	if muted:
		music_player.stream_paused = true
	current_track = (current_track + 1) % tracks.size()

func _on_track_finished():
	play_next_track()

func toggle_mute():
	muted = not muted
	music_player.stream_paused = muted
	menu_music_player.stream_paused = muted
	boss_music_player.stream_paused = muted

func save():
	var save_data = {
		"player_speed": player_speed,
		"bullet_damage": bullet_damage,
		"max_lives": max_lives,
		"current_level": current_level,
		"evasion": evasion
	}
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))

func load_save():
	if not FileAccess.file_exists("user://save.json"):
		return
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	player_speed = data["player_speed"]
	bullet_damage = data["bullet_damage"]
	evasion = data["evasion"]
	max_lives = data["max_lives"]
	current_level = data["current_level"]

var base_volume_db = -40.0

func set_music_volume(percent):
	if percent <= 0 or Global.muted:
		music_player.volume_db = -80
	else:
		music_player.volume_db = base_volume_db + linear_to_db(percent)
		
func start_menu_music():
	menu_music_player.stream_paused = muted
	if not menu_music_player.playing:
		menu_music_player.play()

func stop_menu_music():
	menu_music_player.stop()
	
func fade_out_menu_music(duration = 1.0):
	var tween = create_tween()
	tween.tween_method(func(vol): menu_music_player.volume_db = vol, -40.0, -80.0, duration)
	await tween.finished
	menu_music_player.stop()
	menu_music_player.volume_db = -40
	
#func _process(_delta):
	#print("global process running")
	#if Input.is_action_just_pressed("toggle_fullscreen"):
		#var mode = DisplayServer.window_get_mode()
		#if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		#else:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
func play_click():
	click_player.play()
	
func start_boss_music():
	boss_current_track = 0
	boss_music_player.stream = boss_tracks[boss_current_track]
	boss_music_player.play()

func stop_boss_music():
	boss_music_player.stop()

func _on_boss_track_finished():
	boss_current_track = (boss_current_track + 1) % boss_tracks.size()
	boss_music_player.stream = boss_tracks[boss_current_track]
	boss_music_player.play()
	
var active_perks = []  # взятые перки
var available_perks = ["Shrinker", "BiggerGuns", "GlassCannon", "SecondaryTurrets", "ActiveCamo", "BetterMaterials", "BulletShield", "BaitThem", "RepairDrones", "ExplosiveRounds", "HydraMK1", "LastStand", "Focus"]

func get_random_perk(exclude_last = true):
	var remaining = available_perks.filter(func(p): 
		return not p in active_perks and (not exclude_last or p != last_reroll_perk)
	)
	if remaining.is_empty():
		return ""
	var chosen = remaining[randi() % remaining.size()]
	last_reroll_perk = chosen
	return chosen

func apply_perk(perk_name):
	if perk_name in active_perks:
		return
	active_perks.append(perk_name)
	
var glass_cannon = false
var bait_them = false
var damage_reduction = 0
var active_camo = false
var secondary_turrets = false
var pierce = false
var ricochet = false
var explosive_rounds = false
var hydra = false
var repair_drones = false
var last_stand = false
var last_stand_used = false
var focus = false
var bullet_shield = false
var bullet_scale = 1.0
var extra_upgrade_points = 0
