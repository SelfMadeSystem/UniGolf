extends Node2D

const MIN_SIZE = Vector2(8, 8)
const MAX_SIZE = Vector2(1024, 1024)

const MIN_POSITION = Vector2(0, 0)
const MAX_POSITION = Vector2(1024, 1024)

var grid_size = Vector2(64, 64)
var grid_offset = Vector2(32, 32)

func set_grid_size(size: Vector2):
	grid_size = size
	($Grid.material as ShaderMaterial).set_shader_parameter("cell_size", size)

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
	return Rect2(editing_node.global_position, Vector2(editing_node.width, editing_node.height)).grow(4)

func proceed_to_edit_node(node: Node2D):
	if button_pressed > -1:
		return
	next_node = node

func actually_proceed_to_edit_node(node: Node2D):
	if editing_node:
		editing_node.input_event.disconnect(_on_editing_node_input_event)
		editing_node.tree_exited.disconnect(deyeet)
	editing_node = node
	editing_node.input_event.connect(_on_editing_node_input_event)
	editing_node.tree_exited.connect(deyeet)
	reposition_elements()

func deyeet():
	editing_node = null
	button_pressed = ButtonEnum.NONE
	vanish_elements()

func _process(delta):
	if next_node && editing_node != next_node:
		if button_pressed == -1:
			actually_proceed_to_edit_node(next_node)
		else:
			next_node = null

func reposition_elements():
	var rect = get_rect()
	$Trash.position = rect.position
	$Rotate.position = Vector2(rect.end.x, rect.position.y)
	$Copy.position = Vector2(rect.position.x, rect.end.y)
	$Resize.position = rect.end
	$Line.points = [
		rect.position,
		Vector2(rect.position.x, rect.end.y),
		rect.end,
		Vector2(rect.end.x, rect.position.y),
		rect.position
	]

func vanish_elements():
	$Trash.position = -Vector2.ONE * 69420
	$Rotate.position = -Vector2.ONE * 69420
	$Copy.position = -Vector2.ONE * 69420
	$Resize.position = -Vector2.ONE * 69420
	$Line.points = []

enum ButtonEnum { NONE = -1, RESIZE, ROTATE, INFO, TRASH, COPY, NODE }

var button_pressed: ButtonEnum = ButtonEnum.NONE

func _on_resize_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.RESIZE
			set_mouse_pos(event)

func _on_rotate_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.ROTATE
			editing_node.flipped = (editing_node.flipped + 1) % 4
		elif button_pressed == ButtonEnum.ROTATE:
			button_pressed == ButtonEnum.NONE

func _on_trash_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.TRASH
#			if grid_size == Vector2(32, 32):
#				set_grid_size(Vector2(64, 64))
#			else:
#				set_grid_size(Vector2(32, 32))
			editing_node.queue_free()
			editing_node = null
			vanish_elements()
		elif button_pressed == ButtonEnum.TRASH:
			button_pressed == ButtonEnum.NONE

func _on_copy_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.COPY
			var clone = editing_node.duplicate()
			clone.position += Vector2(16, 16)
			editing_node.add_sibling(clone)
			actually_proceed_to_edit_node(clone)
		elif button_pressed == ButtonEnum.COPY:
			button_pressed == ButtonEnum.NONE

func _on_editing_node_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.NODE
			set_mouse_pos(event)

var mouse_pos = Vector2.ZERO
var og_size = Vector2.ZERO
var og_pos = Vector2.ZERO

func set_mouse_pos(event: InputEventMouseButton):
	mouse_pos = event.position
	og_size = Vector2(editing_node.width, editing_node.height)
	og_pos = editing_node.position

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			button_pressed = ButtonEnum.NONE
	elif event is InputEventMouseMotion:
		if button_pressed < 0:
			return
		var amnt = Vector2(8, 8)
		if $Grid.visible:
			amnt = grid_size
		var diff = event.position - mouse_pos
		match button_pressed:
			ButtonEnum.RESIZE:
				var p = og_size + diff
				var a = editing_node.position.posmodv(amnt)
				p = ((p + grid_offset + a) / amnt).round() * amnt - grid_offset - a
				editing_node.width = p.x
				editing_node.height = p.y
				reposition_elements()
			ButtonEnum.NODE:
				amnt = Vector2.ONE
				var p = og_pos + diff
				editing_node.position = ((p + grid_offset) / amnt).round() * amnt - grid_offset
				reposition_elements()






