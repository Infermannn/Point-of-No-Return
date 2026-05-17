extends Button

func _ready():
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)
	pressed.connect(_on_click)

func _on_hover():
	if not disabled:
		self_modulate = Color(0.7, 0.9, 1, 1)

func _on_exit():
	self_modulate = Color(1, 1, 1, 1)

func _on_click():
	self_modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.05).timeout
	self_modulate = Color(0.7, 0.9, 1, 1)
