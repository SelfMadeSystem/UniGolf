extends Control

var active = false

func activate():
	active = true
	$DraggyThingies.visible = false

func deactivate():
	active = false
	$DraggyThingies.visible = true

func set_selection_box(rect: Rect2):
	position = rect.position
	size = rect.size
	var min_n = Vector2.ONE * 48
	var max_n = get_viewport_rect().size - min_n - Vector2.DOWN * 64
	
	var pos = rect.position.clamp(min_n, max_n)
	var end = rect.end.clamp(min_n, max_n)
	
	$ButtonThingies.global_position = pos
	$ButtonThingies.size = end - pos

func _has_point(_point):
	return active || Rect2(Vector2(), size).has_point(get_local_mouse_position())
#	var global_point = point + global_position
#	for node in GameInfo.node_editor.selected_nodes:
#		if node.contains_point(node.to_local(global_point)):
#			return true
#	return false

func _input(event):
	if !GameInfo.editing:
		deactivate()
		return
	if event is InputEventMouseButton:
		if !event.pressed:
			deactivate()
			return
	if active && GameInfo.node_editor._on_selection_input(event):
		accept_event()

func _gui_input(event):
	if _has_point(event.position):
		if event is InputEventMouseButton:
			if event.pressed:
				activate()
				accept_event()
