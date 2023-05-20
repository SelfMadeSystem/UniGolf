extends Control

@export var level_name: String

var json: JSON




func _on_edit_pressed():
	GameInfo.editing = true
	GameInfo.current_scene = preload("res://scenes/BlankEditor.tscn")
	GameInfo.level_name = json.data.name
	GameInfo.change_scene(json.data, true)
	queue_free()


func _on_delete_pressed():
	DirAccess.remove_absolute(LevelSaver.SAVE_DIR + level_name + ".json")
	_on_cancel_pressed() # TODO: refresh the map list


func _on_cancel_pressed():
	queue_free()


func _on_share_pressed():
	DisplayServer.clipboard_set(JSON.stringify(json.data))
