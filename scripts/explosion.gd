extends Area2D

var damage = 200
var damage_multiplier = 1.0

func _ready():
	connect("area_entered", _on_area_entered)
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(func(): queue_free())
	print("frames count: ", $AnimatedSprite2D.sprite_frames.get_frame_count("default"))

func _on_area_entered(area):
	print("explosion hit: ", area.name, " groups: ", area.get_groups())
	if area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(damage * damage_multiplier * Global.difficulty)
