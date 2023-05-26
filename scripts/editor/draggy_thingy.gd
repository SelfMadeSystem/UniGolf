class_name DraggyThingy

extends Area2D


var attr: EditableNode.DragEditAttribute


@onready var hitball = $hitball


func reposition():
	var val = attr.get_val()
	var pos = attr.start.lerp(attr.end, val)
	var obj = attr.obj
	if obj is ShapedNode:
		pos *= obj.shape_size
	pos += obj.position
	position = pos

func calc_thing(pos: Vector2):
	var min = attr.start
	var max = attr.end
	
	var obj = attr.obj
	if obj is ShapedNode:
		min *= obj.shape_size
		max *= obj.shape_size
	min += obj.position
	max += obj.position
	
	"""
	lerped = min + (max - min) * val # we want to find val
	lerped - min = (max - min) * val
	(lerped - min) / (max - min) = val
	"""
	
	var val = (pos - min) / (max - min)
	
	if abs(val.x) == INF:
		val.x = 0
	if abs(val.y) == INF:
		val.y = 0 # they're inf if they have the same x or y
	
	val.x = clamp(val.x, 0, 1)
	val.y = clamp(val.y, 0, 1)
	
	return clamp(
		val.length(),
		0,
		1
	)

func _ready():
	reposition()

func _input(event):
	if !hitball.visible:
		return
	if GameInfo.node_editor.button_pressed != NodeEditor.ButtonEnum.NONE:
		return

	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			get_viewport().set_input_as_handled() ### TODO:::: USE THIS LIKE EVERYWHERE KUZ I JUST LEARNED ABOUT THIS
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			get_viewport().set_input_as_handled()
			attr.set_val(calc_thing(event.position))
			reposition()

func _on_mouse_entered():
	hitball.show()


func _on_mouse_exited():
	hitball.hide()

func _draw():
	draw_circle(Vector2.ZERO, 16, attr.color)
