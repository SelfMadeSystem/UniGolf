extends Control


func _on_play_pressed():
	var dict = LevelSaver.load_from_file("level")
	GameInfo.change_scene(dict)


func _on_edit_pressed():
	GameInfo.editing = true
	get_tree().change_scene_to_file("res://scenes/BlankEditor.tscn")


func _on_quit_pressed():
	get_tree().quit()
