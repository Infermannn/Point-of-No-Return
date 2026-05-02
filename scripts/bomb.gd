extends Area2D

var speed = 800
var explode_y = 0
var exploded = false

var bullet_scene = preload("res://enemy_bullet.tscn")

func _ready():
	connect("area_entered", _on_area_entered)
	var screen = get_viewport_rect().size
	explode_y = screen.y * randf_range(0.6, 0.8)  

func _process(delta):
	if exploded:
		return
	position.y += speed * delta
	if position.y >= explode_y:
		explode()

func explode():
	exploded = true
	for i in 8:
		var angle = i * PI / 4 
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = dir
		bullet.speed = 600
		bullet.damage = 125
		get_parent().add_child(bullet)
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		exploded = true
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(300)
		queue_free()
