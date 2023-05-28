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
	position = pos

func roundThing(v: float, size: float, offset: float, roundTo: float) -> float:
		return ((roundf((v * size + offset) / roundTo)) * roundTo - offset) / size

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
	
	### FIXME:: Doesn't work if not aligned to grid...
	if min.x == max.x: # round to grid if line is vertical
		var roundTo = GameInfo.node_editor.grid_size.y
		var roundOffset = GameInfo.node_editor.grid_offset.y
		
		if min.y < max.y:
			roundOffset += min.y
		else:
			roundOffset -= min.y
		
		val.y = roundThing(val.y, attr.obj.shape_size.y, roundOffset, roundTo)
		
	elif min.y == max.y: # round to grid if line is horizontal
		var roundTo = GameInfo.node_editor.grid_size.x
		var roundOffset = GameInfo.node_editor.grid_offset.x
		
		if min.x < max.x:
			roundOffset += min.x
		else:
			roundOffset -= min.x
		
		val.x = roundThing(val.x, attr.obj.shape_size.x, roundOffset, roundTo)
	
	val.x = clamp(val.x, 0, 1)
	val.y = clamp(val.y, 0, 1)
	
	return clamp(
		val.length(),
		0,
		1
	)

func _ready():
	reposition()

func _gui_input(event):
	if GameInfo.node_editor.button_pressed != NodeEditor.ButtonEnum.NONE:
		return

	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			accept_event()
	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			accept_event()
			attr.set_val(calc_thing(event.global_position))
			reposition()

func _draw():
	draw_circle(Vector2.ZERO, radius, attr.color)

func _has_point(point):
	var r = radius + click_radius_expand
	return point.length_squared() <= r * r
