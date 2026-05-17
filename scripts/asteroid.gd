extends Area2D

var speed = 300
var player_damage = 300
var enemy_damage = 400

var rotation_speed = randf_range(-0.5, 0.5) 

func _ready():
	connect("area_entered", _on_area_entered)

func _process(delta):
	rotation += rotation_speed * delta
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()

func _on_area_entered(area):
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
		if area.normal_enemy:
			area.die()
		else:
			area.hp -= enemy_damage * Global.difficulty
			if area.hp <= 0:
				area.die()
