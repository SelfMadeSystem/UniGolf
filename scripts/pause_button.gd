class_name PauseButton

extends Button

func _ready():
	if Engine.is_editor_hint():
		return
	get_parent().remove_child.call_deferred(self)
	if GameInfo.pause_button:
		GameInfo.pause_button.get_parent().remove_child.call_deferred(GameInfo.pause_button)
	GameInfo.pause_button = self
	GameInfo.add_child.call_deferred(self)

func _process(__):
	if Input.is_action_just_pressed("pause"):
		GameInfo.pause()

func _on_pressed():
	GameInfo.pause()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if !GameInfo.editing && GameInfo.node_editor != null:
			GameInfo.node_editor.pause()
		elif get_tree() && !get_tree().paused:
			GameInfo.pause()
