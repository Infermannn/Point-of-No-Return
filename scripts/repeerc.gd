extends Area2D

var hp = 400
var speed = 150
var chase_speed = 750
var normal_enemy = true
var counts_as_kill = true

var state = "falling"
var fall_timer = 0
var fall_duration = randf_range(1.0, 2.0)
var blink_timer = 0
var blink_count = 0
var blink_phase = 0

var texture1 = preload("res://Textures/enemies/Repeerc_scaled_10x_pngcrushed.png")
var texture2 = preload("res://Textures/enemies/Repeerc2(1).png")
var explosion_scene = preload("res://explosion.tscn")

var arc_target = Vector2.ZERO
var arc_timer = 0.0
var arc_duration = 1.5  # время движения вниз
var arc_speed = 300.0

var contact_damage = false

func _ready():
	connect("area_entered", _on_area_entered)
	$Sprite2D.texture = texture1
	if Global.endless_mode:
		hp *= Global.endless_enemy_mult

func _process(delta):
	match state:
		"falling":
			$Sprite2D.texture = texture1
			modulate = Color(1, 1, 1, 1)
			position.y += speed * delta
			fall_timer += delta
			if fall_timer >= fall_duration:
				state = "chasing"
		
		"chasing":
			$Sprite2D.texture = texture2
			modulate = Color(1, 1, 1, 1)
			var player = get_tree().get_first_node_in_group("player")
			if player == null:
				return
			var dir = (player.global_position - global_position).normalized()
			position += dir * chase_speed * delta
			var dist = global_position.distance_to(player.global_position)
			
			if dist < 75:  
				state = "blinking"
				blink_timer = 0
				blink_count = 0
				blink_phase = 0
		
		"blinking":
			blink_timer += delta
			var new_phase = int(blink_timer / 0.3)
			if new_phase != blink_phase and new_phase <= 3:
				blink_phase = new_phase
				match blink_phase:
					1:  
						$Sprite2D.texture = texture1
						modulate = Color(1, 0.2, 0.2, 1)
					2:  
						$Sprite2D.texture = texture2
						modulate = Color(1, 1, 1, 1)
					3:  
						$Sprite2D.texture = texture1
						modulate = Color(1, 0.2, 0.2, 1)
						
		"arc_move":
			arc_timer += delta
			# сначала летим вниз
			position.y += arc_speed * delta
			# потом плавно поворачиваем к цели
			if arc_timer > 0.5:
				var dir = (arc_target - global_position).normalized()
				position += dir * arc_speed * delta * (arc_timer - 0.5) * 2
			
			# когда близко к цели - начинаем мигать
			var dist = global_position.distance_to(arc_target)
			if dist < 75 or arc_timer > arc_duration:
				state = "blinking"
				blink_timer = 0
				blink_count = 0
				blink_phase = 0
	
	
	if blink_timer >= 1.0 and state == "blinking":
		explode(1.0)

func explode(damage_multiplier):
	if state == "dead":
		return
	state = "dead"
	modulate = Color(1, 1, 1, 1)
	
	#print("spawning explosion at: ", global_position)
	var exp = explosion_scene.instantiate()
	get_tree().get_first_node_in_group("world").add_child(exp)
	exp.global_position = global_position # устанавливаем ПОСЛЕ add_child
	#print("player pos: ", get_tree().get_first_node_in_group("player").global_position)
	#print("exp position: ", exp.position)
	get_parent().add_child(exp)
	#print("exp added to scene")
	
	queue_free()
	if counts_as_kill:
		get_tree().get_first_node_in_group("world").enemy_killed()

func die():
	explode(0.5)

func hit_flash():
	if state == "blinking":
		return
	modulate = Color(1, 0.2, 0.2, 1)
	await get_tree().create_timer(0.1).timeout
	if state != "blinking":
		modulate = Color(1, 1, 1, 1)

func _on_area_entered(area):
	#print("repeerc hit by: ", area.name, " groups: ", area.get_groups())
	if area.is_in_group("player_bullet"):
		hp -= area.damage
		area.queue_free()
		hit_flash()
		if hp <= 0:
			die()
	if area.is_in_group("asteroid"):
		die()  # или просто queue_free() если не хочешь взрыва
