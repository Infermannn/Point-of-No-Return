extends Control

var slides = []
var current_slide = 0

func _ready():
	slides = [$Slide1, $Slide2, $Slide3, $Slide4, $Slide5]
	for slide in slides:
		slide.visible = false
	$BlackScreen.color = Color(0, 0, 0, 1)
	$IntroMusic.stream = preload("res://Music/Last_Ship_Save.mp3")
	$IntroMusic.play()
	show_slide(0)

func show_slide(index):
	if index >= slides.size():
		go_to_menu()
		return
	
	for slide in slides:
		slide.visible = false
	slides[index].visible = true
	
	var tween = create_tween()
	tween.tween_property($BlackScreen, "color:a", 0.0, 1.0)
	await tween.finished
	
	await get_tree().create_timer(3.0).timeout
	
	var dark_tween = create_tween()
	dark_tween.tween_property($BlackScreen, "color:a", 1.0, 1.0)
	await dark_tween.finished
	
	show_slide(index + 1)

func go_to_menu():
	Global.start_menu_music()
	Global.menu_music_player.volume_db = -80
	
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://menu.tscn")
