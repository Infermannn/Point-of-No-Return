extends Area2D

var damage = 200
var damage_multiplier = 1.0

func _ready():
	connect("area_entered", _on_area_entered)
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(damage * damage_multiplier * Global.difficulty)
