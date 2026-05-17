extends TextureButton

func _ready():
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)
	
	if texture_normal:
		var bitmap = BitMap.new()
		var img = texture_normal.get_image()
		bitmap.create_from_image_alpha(img)
		texture_click_mask = bitmap

func _on_hover():
	pass

func _on_exit():
	pass
