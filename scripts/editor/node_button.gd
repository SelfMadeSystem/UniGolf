extends Control

@export var type: NodeEditor.ButtonEnum

func _gui_input(event):
	var tf = GameInfo.node_editor.on_button_input(event, type, self)
	if tf:
		accept_event()
