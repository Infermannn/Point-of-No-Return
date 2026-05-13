extends Control

var selected = false

func _ready():
	$Ready.disabled = true
	
func select_difficulty(diff, selected_btn):
	Global.difficulty = diff
	selected = true
	$Ready.disabled = false
	# затемняем все кнопки
	$Easy.modulate = Color(1, 1, 1, 0.4)
	$Normal.modulate = Color(1, 1, 1, 0.4)
	$Hard.modulate = Color(1, 1, 1, 0.4)
	# подсвечиваем выбранную
	selected_btn.modulate = Color(1, 1, 1, 1)
	
func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")

func _on_easy_pressed():
	select_difficulty(0.5, $Easy)

func _on_normal_pressed():
	select_difficulty(1.0, $Normal)

func _on_hard_pressed():
	select_difficulty(1.5, $Hard)

func _on_ready_pressed():
	get_tree().change_scene_to_file("res://level1.tscn")
