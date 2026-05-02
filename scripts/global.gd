extends Node


var bullet_damage = 1
var bullet_speed = 500
var max_lives = 3
var current_level = 1
var current_wave = 0

var tutorial_done = false

var player_hp = 300
var player_max_hp = 300
var player_speed = 350
var player_attack_speed = 1.0
var player_attack_damage = 100
var player_bullet_speed = 500
var player_armor = 0

var music_player: AudioStreamPlayer
var tracks = []
var current_track = 0
var muted = false

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -40
	add_child(music_player)
	music_player.finished.connect(_on_track_finished)
	tracks = [
		preload("res://music/Pixel Comet Run.mp3"),
		preload("res://music/Pixel Starfire(1).mp3"),
		preload("res://music/Pixel Starfire.mp3")
	]
	play_next_track()
	
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

func save():
	var save_data = {
		"player_speed": player_speed,
		"bullet_damage": bullet_damage,
		"bullet_speed": bullet_speed,
		"max_lives": max_lives,
		"current_level": current_level
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
	bullet_speed = data["bullet_speed"]
	max_lives = data["max_lives"]
	current_level = data["current_level"]
