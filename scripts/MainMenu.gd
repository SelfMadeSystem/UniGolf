extends Control


func _on_play_pressed():
	pass # Replace with function body.


func _on_edit_pressed():
	GameInfo.editing = true
	get_tree().change_scene_to_file("res://scenes/BlankEditor.tscn")


func _on_quit_pressed():
	get_tree().quit()
