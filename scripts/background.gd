extends Node2D

var scroll_speed = 200

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
	position.y += scroll_speed * delta
	if position.y >= get_viewport_rect().size.y:
		position.y = 0
