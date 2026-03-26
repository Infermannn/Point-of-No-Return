extends Area2D

var speed = 400
var direction = Vector2.ZERO

func _process(delta):
	position += direction * speed * delta
	
	if position.y > 750 or position.y < -50:
		queue_free()
		
func _ready():
	rotation = direction.angle()
