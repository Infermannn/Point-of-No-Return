extends Area2D

var lives = 3

var bullet_scene = preload("res://bullet.tscn")

var speed = 300

var invincible = false

func _ready():
	var screen = get_viewport_rect().size
	position = screen / 2
	connect("area_entered", _on_area_entered)
	set_process(true)

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
		take_damage()
	if area.is_in_group("enemy"):
		area.queue_free()
		take_damage()

func _process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("ui_accept"):
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		get_parent().add_child(bullet)
		
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")
	
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
	position.x = clamp(position.x, 80, 1152 - 75)
	position.y = clamp(position.y, 55, screen.y - 85)
	
func take_damage():
	if invincible:
		return
	invincible = true
	lives -= 1
	if lives <= 0:
		get_tree().change_scene_to_file("res://game_over.tscn")
		return
	var label = get_tree().get_first_node_in_group("lives_label")
	if label != null:
		label.text = "Lives: " + str(lives)
	await get_tree().create_timer(1.0).timeout
	invincible = false


	
	
	
	
	
	
