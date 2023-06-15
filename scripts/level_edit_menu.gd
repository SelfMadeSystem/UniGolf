extends Control

@export var level_name: String

var lvl: Dictionary




func _on_edit_pressed():
	GameInfo.editing = true
	GameInfo.current_scene = preload("res://scenes/BlankEditor.tscn")
	GameInfo.level_name = lvl.get("name")
	GameInfo.change_scene(lvl, true)
	queue_free()


func _on_delete_pressed():
	DirAccess.remove_absolute(LevelSaver.SAVE_DIR + LevelSaver.sanitize_file_name(level_name))
	_on_cancel_pressed() # TODO: refresh the map list


func _on_cancel_pressed():
	queue_free()


func _on_share_pressed():
	DisplayServer.clipboard_set(Marshalls.variant_to_base64(lvl))
