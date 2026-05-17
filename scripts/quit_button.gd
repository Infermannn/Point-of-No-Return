extends TextureButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if texture_normal:
		var bitmap = BitMap.new()
		var img = texture_normal.get_image()
		bitmap.create_from_image_alpha(img)
		texture_click_mask = bitmap
