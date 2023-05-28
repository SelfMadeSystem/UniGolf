extends Control

var selected_nodes: Array[EditableNode] = [] # TODO: Replace this with GameInfo.node_editor.selected_nodes when it exists

var active = false

func _has_point(point):
	return active || Rect2(Vector2(), size).has_point(get_local_mouse_position())
#	var global_point = point + global_position
#	for node in selected_nodes:
#		if node.contains_point(node.to_local(global_point)):
#			return true
#	return false

func _gui_input(event):
	if _has_point(event.position):
		if event is InputEventMouseButton:
			active = event.pressed
		if GameInfo.node_editor._on_selection_input(event):
			accept_event()
