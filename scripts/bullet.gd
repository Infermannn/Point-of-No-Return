extends Node2D

var speed = 600
var damage = 100

func _process(delta):
	position.y -= speed * delta
	
	if position.y < -50:
		queue_free()
