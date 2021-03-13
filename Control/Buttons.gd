extends Control

var min_value = -20.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and name != "TitleScreen" :
		visible = not get_tree().is_paused()
		get_tree().paused = not get_tree().is_paused()
		$OptionsPannel.visible = false

func _on_StartGame_pressed():
	get_tree().change_scene("res://Levels/World_1.tscn")

func _on_OptionsButton_pressed():
	$OptionsPannel.visible = true

func _on_CreditsButton_pressed():
	get_tree().change_scene("res://Levels/Credits.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_ResumeButton_pressed():
	visible = false
	if get_tree().is_paused():
		get_tree().paused = false

func _on_OptionButton_item_selected(index):
	match index:
		0:
			OS.set_window_size(Vector2(1280, 1024))
		1:
			OS.set_window_size(Vector2(1366, 768))
		2:
			OS.set_window_size(Vector2(1920, 1080))
	OS.center_window()

func _on_CheckBoxFullScreen_toggled(button_pressed):
	OS.set_window_fullscreen(not OS.is_window_fullscreen())
	print("dadada")

func _on_BackButton_pressed():
	$OptionsPannel.visible = false

func setVolume(bus , value):
	if value == min_value :
		value = -72
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), value)

func _on_SliderGlobal_value_changed(value):
	setVolume("Master", value)


func _on_SliderMusic_value_changed(value):
	setVolume("Music", value)


func _on_SliderSFX_value_changed(value):
	setVolume("SoundEffects", value)


func _on_ToMenuButton_pressed():
	get_tree().change_scene("res://Control/MainMenu.tscn")





func _on_CheckBoxFullScreen_pressed():
	pass # Replace with function body.
