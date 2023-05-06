class_name NodeEditor

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
var removing_node = false

func _ready():
	if Engine.is_editor_hint():
		return
	GameInfo.node_editor = self
	get_parent().remove_child.call_deferred(self)
	GameInfo.add_child.call_deferred(self)

func get_editing_rect() -> Rect2:
	return Rect2(editing_node.global_position, Vector2(editing_node.width, editing_node.height)).grow(4)

func proceed_to_edit_node(node: Node2D):
	if button_pressed > -1:
		return
	next_node = node
	if !node:
		removing_node = true

func actually_proceed_to_edit_node(node: Node2D):
	if editing_node:
		editing_node.input_event.disconnect(_on_editing_node_input_event)
		editing_node.tree_exited.disconnect(deyeet)
	editing_node = node
	if editing_node:
		editing_node.input_event.connect(_on_editing_node_input_event)
		editing_node.tree_exited.connect(deyeet)
	else:
		next_node = null
	reposition_elements()
	button_pressed = ButtonEnum.NODE
	mouse_pos = null

func deyeet():
	editing_node = null
	button_pressed = ButtonEnum.NONE
	vanish_elements()

func _process(_delta):
	if (next_node || removing_node) && editing_node != next_node:
		removing_node = false
		if button_pressed == -1:
			actually_proceed_to_edit_node(next_node)
		else:
			next_node = null

func reposition_elements():
	if !editing_node:
		vanish_elements()
		return
	var rect = get_editing_rect()
	$Trash.position = rect.position
	$Rotate.position = Vector2(rect.end.x, rect.position.y)
	$Rotate.visible = editing_node.get("flipped") != null
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

enum ActionEnum { DRAG, SELECT, PLACE }

var current_action = ActionEnum.DRAG

var current_object = preload("res://prefabs/wall.tscn")

func set_action(action: ActionEnum):
	current_action = action
	%DragButton.modulate.v = 0.2
	%SelectButton.modulate.v = 0.2
	%PlaceButton.modulate.v = 0.2
	match action:
		ActionEnum.DRAG:
			%DragButton.modulate.v = 1
		ActionEnum.SELECT:
			%SelectButton.modulate.v = 1
		ActionEnum.PLACE:
			%PlaceButton.modulate.v = 1

enum ButtonEnum { NONE = -1, RESIZE, ROTATE, INFO, TRASH, COPY, NODE }

var button_pressed: ButtonEnum = ButtonEnum.NONE

func _on_resize_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.RESIZE
			set_mouse_pos(event.position)

func _on_rotate_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if editing_node.get("flipped") == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.ROTATE
			editing_node.flipped = (editing_node.flipped + 1) % 4
		elif button_pressed == ButtonEnum.ROTATE:
			button_pressed = ButtonEnum.NONE

func _on_trash_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
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
			button_pressed = ButtonEnum.NONE

func _on_copy_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.COPY
			var clone = editing_node.duplicate()
			if $Grid.visible:
				clone.position += grid_size
			else:
				clone.position += Vector2(16, 16)
			editing_node.add_sibling(clone)
			actually_proceed_to_edit_node(clone)
		elif button_pressed == ButtonEnum.COPY:
			button_pressed = ButtonEnum.NONE

func _on_editing_node_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			button_pressed = ButtonEnum.NODE
			set_mouse_pos(event.position)

var mouse_pos = Vector2.ZERO
var og_size = Vector2.ZERO
var og_pos = Vector2.ZERO

func set_mouse_pos(pos: Vector2):
	mouse_pos = pos
	og_size = Vector2(editing_node.width, editing_node.height)
	og_pos = editing_node.position

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			button_pressed = ButtonEnum.NONE
		elif button_pressed == ButtonEnum.NONE:
			proceed_to_edit_node(null)
			var f = func():
				print(button_pressed)
				if button_pressed != ButtonEnum.NONE:
					return
				match current_action:
					ActionEnum.PLACE:
						var node = current_object.instantiate()
						node.width = 64
						node.height = 64
						node.position = event.position
						get_tree().current_scene.add_child(node)
						actually_proceed_to_edit_node(node)
						button_pressed = ButtonEnum.NODE
						set_mouse_pos(event.position)
			f.call_deferred()
	elif event is InputEventMouseMotion:
		if button_pressed < 0:
			return
		if mouse_pos == null:
			set_mouse_pos(event.position)
		var amnt = Vector2(8, 8)
		if $Grid.visible:
			amnt = grid_size
		var diff = event.position - mouse_pos
		match button_pressed:
			ButtonEnum.RESIZE:
				var p = og_size + diff
				var a = editing_node.position.posmodv(amnt)
				p = ((p + grid_offset + a) / amnt).round() * amnt - grid_offset - a
				p = p.clamp(MIN_SIZE, MAX_SIZE)
				editing_node.width = p.x
				editing_node.height = p.y
				reposition_elements()
			ButtonEnum.NODE:
				var p = og_pos + diff
				editing_node.position = ((p + grid_offset) / amnt).round() * amnt - grid_offset
				reposition_elements()

func save_scene():
	var scene = PackedScene.new()
	var result = scene.pack(get_tree().current_scene)
	assert(result == OK)
	return scene





var grid_was_visible = false

func _on_play_button_pressed():
	if GameInfo.editing:
		GameInfo.editing = false
		for node in get_tree().get_nodes_in_group("EditorHide"):
			node.visible = false
		grid_was_visible = $Grid.visible
		$Grid.visible = false
		%PlayButton.texture_normal = preload("res://assets/icons/Pause.png")
		var stuff = LevelSaver.serialize_level()
		GameInfo.current_level = stuff
		get_tree().change_scene_to_packed(preload("res://scenes/Blank.tscn"))
		LevelSaver.deserialize_level.bind(stuff).call_deferred()
	else:
		GameInfo.editing = true
		for node in get_tree().get_nodes_in_group("EditorHide"):
			node.visible = true
		$Grid.visible = grid_was_visible
		%PlayButton.texture_normal = preload("res://assets/icons/Play.png")
		GameInfo.reload_scene()

func _on_grid_button_pressed():
	if $Grid.visible:
		if grid_size.x > 32:
			set_grid_size(Vector2(32, 32))
			%GridButton.texture_normal = preload("res://assets/icons/Grid_Small.png")
		else:
			$Grid.visible = false
			%GridButton.texture_normal = preload("res://assets/icons/Grid.png")
			%GridButton.modulate.v = 0.3
	else:
		$Grid.visible = true
		set_grid_size(Vector2(64, 64))
		%GridButton.modulate.v = 1


func _on_drag_button_pressed():
	set_action(ActionEnum.DRAG)


func _on_select_button_pressed():
	set_action(ActionEnum.SELECT)

func _on_place_button_pressed():
	set_action(ActionEnum.PLACE)

func _on_objects_button_pressed():
	var selectScene = preload("res://prefabs/object_select.tscn")
	var select = selectScene.instantiate()
	$UI.add_child(select)
	select.add_object({
		"prefab": preload("res://prefabs/wall.tscn"),
		"name": "Wall"
	})
	select.add_object({
		"prefab": preload("res://prefabs/wall_angled.tscn"),
		"name": "Wall"
	})
	select.add_object({
		"prefab": preload("res://prefabs/water.tscn"),
		"name": "Water"
	})
	select.add_object({
		"prefab": preload("res://prefabs/water_angled.tscn"),
		"name": "Water"
	})
	select.selected.connect(func(a):
		%PlaceButton.get_child(0).queue_free()
		var b = a.instantiate()
		b.width = 48
		b.height = 48
		b.position = Vector2(8, 8)
		%PlaceButton.add_child(b)
		current_object = a
		set_action(ActionEnum.PLACE)
	)


func _on_leave_button_pressed():
	# TODO: Save
	GameInfo.to_main_menu()
