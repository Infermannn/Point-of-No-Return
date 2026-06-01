extends Area2D

var speed = 500
var damage = 100
var pierce = false
var pierce_damage_mult = 1.0
var hit_enemies = []
var has_ricocheted = false
var bullet_scene = preload("res://bullet.tscn")

var direction = Vector2(0, -1)

var pierced_once = false 

func _process(delta):
	position += direction * speed * delta
	if position.y < -50:
		queue_free()

func _on_area_entered(area):
	print("pierce check: ", Global.pierce, " pierce: ", pierce)
	print("bullet hit: ", area.name, " groups: ", area.get_groups())
	if area.is_in_group("enemy"):
		if area in hit_enemies:
			return
		hit_enemies.append(area)
		area.hp -= damage * pierce_damage_mult
		if area.hp <= 0:
			area.die()
		
		
		if Global.pierce:
			if not pierced_once:
				pierced_once = true
				pierce_damage_mult = 0.4
				return
			else:
				queue_free()
				return

		queue_free()
