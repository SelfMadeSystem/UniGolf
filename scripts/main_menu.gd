extends Control

var load_level_scene = preload("res://scenes/LoadLevelMenu.tscn")

func _on_play_pressed():
	GameInfo.current_scene = preload("res://scenes/Blank.tscn")
	get_tree().change_scene_to_packed(load_level_scene)


func _on_edit_pressed():
	var load_level = load_level_scene.instantiate()
	load_level.button_pressed = func(json):
		var level_edit_menu = preload("res://prefabs/LevelEditMenu.tscn")
		var inst = level_edit_menu.instantiate()
		inst.json = json
		inst.level_name = json.data.name
		GameInfo.get_tree().root.add_child(inst)

	load_level.set_bottom_button = func(button: Button, _maps):
		button.text = "Create New Level"
	load_level.bottom_pressed = func():
		GameInfo.editing = true
		# Must use GameInfo.get_tree() or else this lambda will depend on the main menu that no longer exists
		GameInfo.get_tree().change_scene_to_file("res://scenes/BlankEditor.tscn")
	get_tree().root.add_child(load_level)
	get_tree().current_scene = load_level
	queue_free()


func _on_quit_pressed():
	get_tree().quit()
