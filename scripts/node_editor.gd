extends Node2D

const MIN_SIZE = 8
const MAX_SIZE = 128

const MIN_POSITION = 0
const MAX_POSITION = 128

# Assume properties on node:
# width: int
# height: int
# position: Vector2
# flipped?: int from 0 to 3
#
# And assume that setting width and height will automatically properly
# scale the node's hitbox, sprite etc.
var editing_node: Node2D
var next_node: Node2D

func get_rect() -> Rect2:
	return Rect2(editing_node.global_position, Vector2(editing_node.width, editing_node.height) * 8)

func proceed_to_edit_node(node: Node2D):
	if button_pressed > -1:
		return
	next_node = node

func _process(delta):
	if next_node && editing_node != next_node:
		if button_pressed == -1:
			if editing_node:
				editing_node.input_event.disconnect(_on_editing_node_input_event)
			editing_node = next_node
			editing_node.input_event.connect(_on_editing_node_input_event)
			reposition_elements()
		else:
			next_node = null

func reposition_elements():
	var rect = get_rect()
	$Trash.position = rect.position
	$Rotate.position = Vector2(rect.end.x, rect.position.y)
	$Copy.position = Vector2(rect.position.x, rect.end.y)
	$Resize.position = rect.end

enum ButtonEnum { NONE = -1, RESIZE, ROTATE, INFO, TRASH, COPY, NODE }

var button_pressed: ButtonEnum = ButtonEnum.NONE

func _on_resize_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.RESIZE

func _on_rotate_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.ROTATE
			editing_node.flipped = (editing_node.flipped + 1) % 4
		elif button_pressed == ButtonEnum.ROTATE:
			button_pressed == ButtonEnum.NONE

func _on_editing_node_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.NODE

var mouse_rel_accum = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			button_pressed = ButtonEnum.NONE
			mouse_rel_accum = Vector2.ZERO
	elif event is InputEventMouseMotion:
		match button_pressed:
			ButtonEnum.RESIZE:
				mouse_rel_accum += event.relative
				editing_node.width = clamp(editing_node.width + (mouse_rel_accum.x as int) / 8, MIN_SIZE, MAX_SIZE)
				editing_node.height = clamp(editing_node.height + (mouse_rel_accum.y as int) / 8, MIN_SIZE, MAX_SIZE)
				mouse_rel_accum.x = fmod(mouse_rel_accum.x, 8)
				mouse_rel_accum.y = fmod(mouse_rel_accum.y, 8)
				reposition_elements()
			ButtonEnum.NODE:
				mouse_rel_accum += event.relative
				editing_node.position.x = clamp(editing_node.position.x / 8 + (mouse_rel_accum.x as int) / 8, MIN_POSITION, MAX_POSITION) * 8
				editing_node.position.y = clamp(editing_node.position.y / 8 + (mouse_rel_accum.y as int) / 8, MIN_POSITION, MAX_POSITION) * 8
				mouse_rel_accum.x = fmod(mouse_rel_accum.x, 8)
				mouse_rel_accum.y = fmod(mouse_rel_accum.y, 8)
				reposition_elements()

