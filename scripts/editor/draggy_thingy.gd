class_name DraggyThingy

extends Control

@export var radius: float = 16
@export var click_radius_expand: float = 8
var attr: EditableNode.DragEditAttribute

func reposition():
	var val = attr.get_val()
	var pos = attr.start.lerp(attr.end, val)
	var obj = attr.obj
	if obj is ShapedNode:
		pos *= obj.shape_size
	pos += obj.position
	global_position = pos

@warning_ignore("SHADOWED_VARIABLE_BASE_CLASS")
func round_thing(v: float, size: float, offset: float, round_to: float) -> float:
	return ((roundf((v * size + offset) / round_to)) * round_to - offset) / size

func calc_thing(pos: Vector2):
	var min_n = attr.start
	var max_n = attr.end
	
	var obj = attr.obj
	if obj is ShapedNode:
		min_n *= obj.shape_size
		max_n *= obj.shape_size
	min_n += obj.position
	max_n += obj.position
	
	"""
	lerped = min + (max - min) * val # we want to find val
	lerped - min = (max - min) * val
	(lerped - min) / (max - min) = val
	"""
	
	var val = (pos - min_n) / (max_n - min_n)
	
	if abs(val.x) == INF:
		val.x = 0
	if abs(val.y) == INF:
		val.y = 0 # they're inf if they have the same x or y
	
	if min_n.x == max_n.x: # round to grid if line is vertical
		var roundTo = GameInfo.node_editor.grid_size.y
		var roundOffset = GameInfo.node_editor.grid_offset.y
		
		if min_n.y < max_n.y:
			roundOffset += min_n.y
		else:
			roundOffset -= min_n.y
		
		val.y = round_thing(val.y, attr.obj.shape_size.y, roundOffset, roundTo)
		
	elif min_n.y == max_n.y: # round to grid if line is horizontal
		var roundTo = GameInfo.node_editor.grid_size.x
		var roundOffset = GameInfo.node_editor.grid_offset.x
		
		if min_n.x < max_n.x:
			roundOffset += min_n.x
		else:
			roundOffset -= min_n.x
		
		val.x = round_thing(val.x, attr.obj.shape_size.x, roundOffset, roundTo)
	
	val.x = clamp(val.x, 0, 1)
	val.y = clamp(val.y, 0, 1)
	
	return clamp(
		val.length(),
		0,
		1
	)

func _ready():
	reposition()

var dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			dragging = false

func _gui_input(event):
	if GameInfo.node_editor.button_pressed != NodeEditor.ButtonEnum.NONE:
		return

	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT != 0 && event.pressed:
			dragging = true
			accept_event()
	elif event is InputEventMouseMotion:
		if dragging:
			accept_event()
			attr.set_val(calc_thing(event.global_position))
			reposition()

func _draw():
	draw_circle(Vector2.ZERO, radius, attr.color)

func _has_point(point):
	var r = radius + click_radius_expand
	return point.length_squared() <= r * r
