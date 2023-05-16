extends Control


func _on_play_pressed():
	GameInfo.current_scene = preload("res://scenes/Blank.tscn")
	get_tree().change_scene_to_file("res://scenes/LoadLevelMenu.tscn")


func _on_edit_pressed():
	GameInfo.editing = true
	get_tree().change_scene_to_file("res://scenes/BlankEditor.tscn")


func _on_quit_pressed():
	get_tree().quit()
