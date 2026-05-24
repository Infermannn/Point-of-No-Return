extends Control

var selected = false
var animating = false

func _ready():
	$Ready.disabled = true
	$Ready.modulate = Color(1, 1, 1, 0.4)
	$BackgroundContainer.scroll_speed = 1500

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE) and not animating:
		get_tree().change_scene_to_file("res://menu.tscn")

func select_difficulty(diff, selected_btn):
	Global.difficulty = diff
	selected = true
	$Ready.disabled = false
	$Ready.modulate = Color(1, 1, 1, 1)
	$Easy.modulate = Color(1, 1, 1, 1)
	$Normal.modulate = Color(1, 1, 1, 1)
	$Hard.modulate = Color(1, 1, 1, 1)
	$Easy.disabled = false
	$Normal.disabled = false
	$Hard.disabled = false
	selected_btn.modulate = Color(1, 1, 1, 0.4)
	selected_btn.disabled = true

func _on_easy_pressed():
	select_difficulty(0.8, $Easy)
	Global.click_player.play()

func _on_normal_pressed():
	select_difficulty(1.0, $Normal)
	Global.click_player.play()

func _on_hard_pressed():
	select_difficulty(1.4, $Hard)
	Global.click_player.play()

func _on_ready_pressed():
	Global.click_player.play()
	if animating:
		return
	animating = true
	Global.fade_out_menu_music(1.0)
	play_transition()

func play_transition():
	var tween = create_tween()
	tween.tween_property($Easy, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property($Normal, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property($Hard, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property($Ready, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	$BigBullet.visible = true
	var screen = get_viewport_rect().size
	$BigBullet.position = Vector2(screen.x / 2, -50)
	var bullet_tween = create_tween()
	bullet_tween.tween_property($BigBullet, "position", $PlayerShip.position, 0.5)
	
	await bullet_tween.finished
	
	$BlackScreen.color = Color(0, 0, 0, 1)
	$BlackScreen.visible = true
	$BlackScreen.modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(0.3).timeout

	get_tree().change_scene_to_file("res://level1.tscn")
