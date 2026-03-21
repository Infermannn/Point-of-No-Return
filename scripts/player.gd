extends Node2D

var speed = 300

func _process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	
	position += direction * speed * delta
	var screen = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen.x)
	position.y = clamp(position.y, 0, screen.y)
	
	
