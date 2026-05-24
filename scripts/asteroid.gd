extends Area2D

var speed = 0
var rotation_speed = 0
var direction = Vector2.DOWN
var size_scale = 1.0
var player_damage = 0
var fixed_enemy_damage = 0
var boss_damage = 0
var hit_enemies = []
var is_small = false

func _ready():
	connect("area_entered", _on_area_entered)
	
	if is_small:
		$Sprite2D.scale = Vector2(0.25, 0.25)
		size_scale = 0.5
		fixed_enemy_damage = 25
		boss_damage = 50
		player_damage = 100
	else:
		$Sprite2D.scale = Vector2(0.5, 0.5)
		size_scale = 1.0
		fixed_enemy_damage = 75
		boss_damage = 100
		player_damage = 200
	
	var base_radius = $CollisionShape2D.shape.radius
	var new_shape = CircleShape2D.new()
	new_shape.radius = base_radius * size_scale
	$CollisionShape2D.shape = new_shape
	
	speed = randf_range(150, 450)
	rotation_speed = randf_range(-1.0, 1.0)
	
	var angle = randf_range(-15, 15)
	direction = Vector2(sin(deg_to_rad(angle)), cos(deg_to_rad(angle)))

func _process(delta):
	rotation += rotation_speed * delta
	position += direction * speed * delta
	if position.y > get_viewport_rect().size.y + 100 or position.x < -100 or position.x > get_viewport_rect().size.x + 100:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("asteroid"):
		if size_scale > area.size_scale:
			area.queue_free()
		return
	
	if area.is_in_group("player_bullet") or area.is_in_group("enemy_bullet"):
		area.queue_free()
		return
	
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(player_damage * Global.difficulty)
		queue_free()
		return
	
	if area.is_in_group("enemy"):
		if area in hit_enemies:
			return
		hit_enemies.append(area)
		
		if area.get_script() and area.get_script().resource_path.contains("repeerc"):
			area.hp -= 999
			if area.hp <= 0:
				area.die()
		elif area.normal_enemy:
			area.hp -= fixed_enemy_damage
			if area.hp <= 0:
				area.die()
		else:
			area.hp -= boss_damage
			if area.hp <= 0:
				area.die()
