extends Control

func _on_play_pressed():
	GameInfo.current_scene = preload("res://scenes/Blank.tscn")
	get_tree().change_scene_to_file("res://scenes/MapPackSelect.tscn")


func _on_edit_pressed():
	var load_level = preload("res://scenes/EditSelectLevelMenu.tscn").instantiate()

	get_tree().root.add_child(load_level)
	get_tree().current_scene = load_level
	queue_free()


func _on_quit_pressed():
	get_tree().quit()
