extends Control

@export var level_name: String

var lvl: Dictionary

var menu: EditSelectLevelMenu


func _on_edit_pressed():
	GameInfo.editing = true
	GameInfo.current_scene = preload("res://scenes/BlankEditor.tscn")
	GameInfo.change_scene(lvl, true)
	queue_free()


func _on_delete_pressed():
	DirAccess.remove_absolute(LevelSaver.CUSTOM_DIR + LevelSaver.sanitize_file_name(level_name))
	menu.reload()
	_on_cancel_pressed()


func _on_cancel_pressed():
	queue_free()


func _on_share_pressed():
	DisplayServer.clipboard_set(Marshalls.variant_to_base64(lvl))
