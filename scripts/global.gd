extends Node


var bullet_damage = 1
var bullet_speed = 600
var max_lives = 3
var current_level = 1
var current_wave = 0


var player_hp = 300
var player_max_hp = 300
var player_speed = 350
var player_attack_speed = 1.0
var player_attack_damage = 100
var player_bullet_speed = 600
var player_armor = 0

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
