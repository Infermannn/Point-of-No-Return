extends Area2D

var speed = 300
var hp = 300
var max_hp = 300
var attack_speed = 0.3 
var shoot_timer = 0.0
var bullet_damage = 100
var bullet_speed = 600
var godmode = false

var bullet_scene = preload("res://bullet.tscn")



var invincible = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen = get_viewport_rect().size
	position = screen / 2
	connect("area_entered", _on_area_entered)
	set_process(true)

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
		take_damage(100)
	if area.is_in_group("enemy"):
		area.queue_free()
		take_damage(100)

func _process(delta):
	
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_SHIFT) and Input.is_action_just_pressed("toggle_godmode"):
		godmode = not godmode
		print("Godmode: ", godmode)
	
	var direction = Vector2.ZERO
	shoot_timer -= delta
	
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot_timer = attack_speed
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.damage = bullet_damage 
		get_parent().add_child(bullet)
		
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://menu.tscn")
		return
	
	if get_tree().paused:
		return
	
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
	position.x = clamp(position.x, 80, 1920 - 75)
	position.y = clamp(position.y, 55, screen.y - 85)
	
func take_damage(amount):
	if invincible or godmode:
		return
	invincible = true
	hp -= amount
	if hp <= 0:
		get_tree().change_scene_to_file("res://game_over.tscn")
		return
	var label = get_tree().get_first_node_in_group("lives_label")
	if label != null:
		label.text = "HP: " + str(hp) + "/" + str(max_hp)
	await get_tree().create_timer(1.0).timeout
	invincible = false


	
	
	
	
	
	
