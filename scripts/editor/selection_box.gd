extends Control

var selected_nodes: Array[EditableNode] = [] # TODO: Replace this with GameInfo.node_editor.selected_nodes when it exists

var active = false

func activate():
	active = true
	$DraggyThingies.visible = false

func deactivate():
	active = false
	$DraggyThingies.visible = true

func _has_point(point): # TODO: Figure out how to solve conflict between this and draggy thingy
	return active || Rect2(Vector2(), size).has_point(get_local_mouse_position())
#	var global_point = point + global_position
#	for node in selected_nodes:
#		if node.contains_point(node.to_local(global_point)):
#			return true
#	return false

func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			deactivate()
	if active && GameInfo.node_editor._on_selection_input(event):
		accept_event()

func _gui_input(event):
	if _has_point(event.position):
		if event is InputEventMouseButton:
			if event.pressed:
				activate()
