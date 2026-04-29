extends Node2D

var scroll_speed = 200

func _process(delta):
	position.y += scroll_speed * delta
	if position.y >= 1080:
		position.y = 0
