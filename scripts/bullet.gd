extends Area2D

var speed = 500
var damage = 100
var pierce = false
var pierce_damage_mult = 1.0
var hit_enemies = []
var has_ricocheted = false
var bullet_scene = preload("res://bullet.tscn")

var direction = Vector2(0, -1)  # по умолчанию вверх

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
		
		# ricochet
		#print("ricochet check: ", Global.ricochet, " has_ricocheted: ", has_ricocheted)
		#if Global.ricochet and not has_ricocheted and randf() < 0.25:
			#print("ricochet triggered!")
			#var closest = null
			#var closest_dist = INF
			#for enemy in get_tree().get_nodes_in_group("enemy"):
				#if enemy == area:
					#continue
				#var dist = global_position.distance_to(enemy.global_position)
				#if dist < closest_dist:
					#closest_dist = dist
					#closest = enemy
			
			#if closest:
				#var ricochet_bullet = bullet_scene.instantiate()
				#ricochet_bullet.position = global_position
				#ricochet_bullet.direction = (closest.global_position - global_position).normalized()
				#ricochet_bullet.damage = 100
				#ricochet_bullet.has_ricocheted = true
				#if Global.pierce:
					#ricochet_bullet.pierce = true
					#ricochet_bullet.pierce_damage_mult = 1.0
				#get_parent().add_child(ricochet_bullet)
			#queue_free()
			#return  # добавь return!
		
		# pierce
		# pierce
		if Global.pierce:
			if not pierced_once:
				pierced_once = true
				pierce_damage_mult = 0.4
				return  # пробиваем первого врага насквозь
			else:
				queue_free()  # после второго удаляемся
				return

		queue_free()
