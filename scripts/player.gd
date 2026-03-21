extends Node2D

var bullet_scene = preload("res://bullet.tscn")

var speed = 300

func _ready():
	var screen = get_viewport_rect().size
	position = screen / 2

func _process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_accept"):
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		get_parent().add_child(bullet)
	
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
	position.x = clamp(position.x, 80, screen.x - 75)
	position.y = clamp(position.y, 55, screen.y - 85)
	
	
