extends Node2D

var scroll_speed = 200

var base_speed = 200
var target_speed = 200
var speed_change_rate = 0

func _ready():
	var screen = get_viewport_rect().size
	
	var bg1 = $Background
	var bg2 = $Background2
	
	var texture_size = bg1.texture.get_size()
	var scale_factor = screen / texture_size
	
	bg1.scale = scale_factor
	bg2.scale = scale_factor
	
	bg1.position = Vector2(screen.x / 2, screen.y / 2)
	bg2.position = Vector2(screen.x / 2, -screen.y / 2)

func _process(delta):
	if speed_change_rate != 0:
		scroll_speed = move_toward(scroll_speed, target_speed, speed_change_rate * delta)
	position.y += scroll_speed * delta
	if position.y >= get_viewport_rect().size.y:
		position.y = 0

func speed_up():
	target_speed = 2000
	speed_change_rate = 1500

func slow_down():
	target_speed = base_speed
	speed_change_rate = 1500
	
