extends Area2D

var speed = 400
var direction = Vector2.ZERO
var damage = 50

func _process(delta):
	position += direction * speed * delta
	
	if position.y > 1080 or position.y < -50:
		queue_free()
		
func _ready():
	rotation = direction.angle()
