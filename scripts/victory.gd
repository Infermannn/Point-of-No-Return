extends Control

func _ready():
	$BlackScreen.color = Color(0, 0, 0, 1)
	
	var tween = create_tween()
	tween.tween_property($BlackScreen, "color:a", 0.0, 1.0)
	await tween.finished
	
	await shake_and_explode()
	
	var dark_tween = create_tween()
	dark_tween.tween_property($BlackScreen, "color:a", 1.0, 1.0)
	await dark_tween.finished
	
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://menu.tscn")

func shake_and_explode():
	var boss_sprite = $BossSprite
	var textures = [
		preload("res://Textures/Mothership/mothership_2_dim(2).png"),
		preload("res://Textures/Mothership/mothership_4_bright(1).png"),
		preload("res://Textures/Mothership/mothership_3_medium(1).png")
	]
	var original_pos = boss_sprite.position
	var shake_timer = 0.0
	var texture_index = 0
	var texture_timer = 0.0
	
	while shake_timer < 3.0:
		boss_sprite.position = original_pos + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		texture_timer += 0.05
		if texture_timer >= 0.1:
			texture_timer = 0.0
			texture_index = (texture_index + 1) % textures.size()
			boss_sprite.texture = textures[texture_index]
		shake_timer += 0.05
		await get_tree().create_timer(0.05).timeout
	
	boss_sprite.position = original_pos
	boss_sprite.visible = false
	
	var screen = get_viewport_rect().size
	var explosion_rect = ColorRect.new()
	explosion_rect.color = Color(1, 0.5, 0, 1)
	explosion_rect.size = Vector2(10, 10)
	explosion_rect.position = boss_sprite.position - Vector2(5, 5)
	explosion_rect.z_index = 90
	add_child(explosion_rect)
	
	var exp_tween = create_tween()
	exp_tween.tween_property(explosion_rect, "size", screen, 0.3)
	exp_tween.parallel().tween_property(explosion_rect, "position", Vector2.ZERO, 0.3)
	await exp_tween.finished
