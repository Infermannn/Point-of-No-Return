extends Control

var messages = [
	{"text": "Welcome, pilot! \n\nEarth is under threat.\n\nPress Z to continue.", "type": "enter"},
	{"text": "Use WASD to move your ship.\n\nPress each key at least once.", "type": "wasd"},
	{"text": "Press SPACE to shoot.\n\nTry firing your weapons!", "type": "shoot"},
	{"text": "Well done! \n\nDestroy all enemies to protect the planet!\n\nPress Z to begin.", "type": "enter"}
]

var current = 0
var pressed_keys = {}

func _ready():
	show_message()

var finished = false

func show_message():
	get_tree().get_first_node_in_group("tutorial_text").text = messages[current]["text"]
	pressed_keys = {}

func _process(_delta):
	if finished:
		return
	
	var msg = messages[current]
	
	if msg["type"] == "enter":
		if Input.is_key_pressed(KEY_Z):
			next_message()
	
	elif msg["type"] == "wasd":
		if Input.is_key_pressed(KEY_W): pressed_keys["w"] = true
		if Input.is_key_pressed(KEY_A): pressed_keys["a"] = true
		if Input.is_key_pressed(KEY_S): pressed_keys["s"] = true
		if Input.is_key_pressed(KEY_D): pressed_keys["d"] = true
		if pressed_keys.size() >= 4:
			next_message()
	
	elif msg["type"] == "shoot":
		if Input.is_key_pressed(KEY_SPACE):
			pressed_keys["shoot"] = true
		if pressed_keys.has("shoot"):
			next_message()

func next_message():
	current += 1
	if current >= messages.size():
		finish_tutorial()
	else:
		show_message()

func finish_tutorial():
	finished = true
	hide()
	get_tree().get_first_node_in_group("world").start_game()
