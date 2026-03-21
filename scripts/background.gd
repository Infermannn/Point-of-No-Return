extends Sprite2D

func _ready():
	var screen = get_viewport_rect().size
	var texture_size = texture.get_size()
	scale = screen / texture_size
	position = screen / 2
