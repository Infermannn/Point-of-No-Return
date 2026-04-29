extends Area2D

var speed = 800
var direction = Vector2.ZERO
var damage = 200
var rotated = false

func _process(delta):
	if not rotated:
		rotation = direction.angle() + PI
		rotated = true
	
	position += direction * speed * delta
	
	if position.y > 1200 or position.y < -100 or position.x < -100 or position.x > 2100:
		queue_free()
