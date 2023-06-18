class_name NodeEditor

extends Node2D

const MIN_SIZE = Vector2(8, 8)
const MAX_SIZE = Vector2(1024, 1024)

const MIN_POSITION = Vector2(0, 0)
const MAX_POSITION = Vector2(1024, 1024)

const GRID_BIG = Vector2.ONE * 32
const GRID_SMALL = Vector2.ONE * 16
const GRID_NONE = Vector2.ONE

var grid_size = GRID_BIG
var grid_offset = Vector2.ZERO

func set_grid_size(size: Vector2):
	grid_size = size
	($Grid.material as ShaderMaterial).set_shader_parameter("cell_size", size)

var selected_nodes: Array[EditableNode] = []
var menu_edit_attributes: Array[EditableNode.EditAttribute] = []
var visible_edit_attributes: Array[EditableNode.DragEditAttribute] = []
var draggy_thingies: Array[DraggyThingy] = []

func _ready():
	if Engine.is_editor_hint():
		return
	set_grid_size(GRID_BIG)
	GameInfo.current_scene = preload("res://scenes/BlankPlaytest.tscn")
	GameInfo.node_editor = self
	set_current_object(preload("res://prefabs/nodes/wall.tscn"))
	get_parent().remove_child.call_deferred(self)
	GameInfo.add_child.call_deferred(self)
	%Name.text = GameInfo.level_name
	($Grid.material as ShaderMaterial).set_shader_parameter("offset", grid_offset)

func get_editing_rect() -> Rect2:
	var min = Vector2.INF
	var max = -Vector2.INF
	
	for node in selected_nodes:
		var rect = node.get_bounding_rect()
		min = min.clamp(-Vector2.INF, rect.position)
		max = max.clamp(rect.position + rect.size, Vector2.INF)
	return Rect2(min, max - min)

func proceed_to_edit_nodes(nodes: Array[EditableNode], edit = true):
	for node in selected_nodes:
#		node.input_event.disconnect(_on_editing_node_input_event)
		node.tree_exited.disconnect(deyeet)
		node.should_update_stuff.disconnect(update_the_stuffs)
	selected_nodes.clear()
	selected_nodes.append_array(nodes)
	for node in selected_nodes:
#		node.input_event.connect(_on_editing_node_input_event)
		node.tree_exited.connect(deyeet)
		node.should_update_stuff.connect(update_the_stuffs)
	mouse_pos = Vector2.INF
	
	if nodes.size() == 0:
		vanish_elements()
		return
	
	update_editing_node_attributes()
	reposition_elements()
	
	if edit:
		%SelectionBox.activate()

func update_the_stuffs():
	update_editing_node_attributes()
	reposition_elements()

func update_editing_node_attributes():
	for thing in draggy_thingies:
		thing.queue_free()
	draggy_thingies.clear()
	menu_edit_attributes.clear()
	visible_edit_attributes.clear()
	
	if selected_nodes.size() > 1:
		return
	
	for node in selected_nodes:
		menu_edit_attributes.append_array(node.get_menu_edit_attributes())
		visible_edit_attributes.append_array(node.get_visible_edit_attributes())
	for attr in visible_edit_attributes:
		var thing = preload("res://prefabs/editor/draggy_thingy.tscn").instantiate()
		thing.attr = attr
		%DraggyThingies.add_child.call_deferred(thing)
		draggy_thingies.append(thing)

func reposition_draggy_thingies():
	for thing in draggy_thingies:
		thing.reposition()

func deyeet():
	proceed_to_edit_nodes([])
	button_pressed = ButtonEnum.NONE
	vanish_elements()

func set_line(rect: Rect2):
	$Line.points = [
		rect.position,
		Vector2(rect.position.x, rect.end.y),
		rect.end,
		Vector2(rect.end.x, rect.position.y),
		rect.position
	]
	($Line.material as ShaderMaterial).set_shader_parameter("pos", rect.position);
	($Line.material as ShaderMaterial).set_shader_parameter("end", rect.end);

func reposition_elements():
	if selected_nodes.size() == 0:
		vanish_elements()
		return
	var rect = get_editing_rect()
	%SelectionBox.set_selection_box(rect)
	%EditButton.disabled = selected_nodes.size() != 1
	set_line(rect.grow(2))
	reposition_draggy_thingies()

func vanish_elements():
	for thing in draggy_thingies:
		thing.queue_free()
	draggy_thingies = []
	%SelectionBox.position = Vector2.ONE * 69420
	%EditButton.disabled = true
	$Line.points = []

enum ActionEnum { DRAG, SELECT, PLACE }

var current_action = ActionEnum.DRAG

var current_object = preload("res://prefabs/nodes/wall.tscn")

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

enum ButtonEnum { NONE, RESIZE, ROTATE, INFO, TRASH, COPY, NODE }

var button_pressed: ButtonEnum = ButtonEnum.NONE

func on_button_input(event: InputEvent, type: ButtonEnum, button: Control):
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			match type:
				ButtonEnum.RESIZE:
					button_pressed = ButtonEnum.RESIZE
					set_mouse_pos(get_viewport().get_mouse_position())
					return true
				ButtonEnum.ROTATE:
					var rect = get_editing_rect()
					for node in selected_nodes:
						if node.has_method("rotate_ccw"):
							node.rotate_ccw(rect)
					return true
				ButtonEnum.TRASH:
					for node in selected_nodes:
						node.queue_free()
					proceed_to_edit_nodes([])
					return true
				ButtonEnum.COPY:
					var clones: Array[EditableNode] = []
					for node in selected_nodes:
						var clone = node.duplicate()
						node.add_sibling(clone)
						clones.append(clone)
					proceed_to_edit_nodes(clones)
					return true
	return false

func _on_selection_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT == 0:
			return false
		if selected_nodes.size() == 0:
			return false
		var mpos = get_viewport().get_mouse_position()
		if mouse_pos == Vector2.INF:
			set_mouse_pos(mpos)
		var diff = mpos - mouse_pos
		var p = og_pos + diff
		
		var top_left = get_editing_rect().position
		
		var new_pos = ((p + grid_offset) / grid_size).round() * grid_size - grid_offset
		
		var pos_diff = new_pos - top_left
		
		for node in selected_nodes:
			node.position += pos_diff
			node.var_updated()
		
		reposition_elements()
		return true


func handle_object_input(object: EditableNode, event: InputEvent):
	if GameInfo.editing && current_action == ActionEnum.DRAG && event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			if object.get_parent() is Control:
				return
			proceed_to_edit_nodes([object])

func remove_out_of_bounds():
	var rect = get_viewport_rect().grow(-1)
	rect.size.y -= 64
	var nodes_not_removed: Array[EditableNode] = []
	for node in selected_nodes:
		if !rect.intersects(node.get_bounding_rect()):
			node.queue_free()
		else:
			nodes_not_removed.append(node)
	if nodes_not_removed.size() != selected_nodes.size():
		proceed_to_edit_nodes(nodes_not_removed)

var mouse_pos = Vector2.INF
var og_size = Vector2.ZERO
var og_pos = Vector2.ZERO

var drag_start = Vector2.INF
var dragging = false

func set_mouse_pos(pos: Vector2):
	mouse_pos = pos
	var og_rect = get_editing_rect()
	og_size = og_rect.size
	og_pos = og_rect.position

func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			button_pressed = ButtonEnum.NONE
			dragging = false
			mouse_pos = Vector2.INF
			if !GameInfo.editing:
				return
			match current_action:
				ActionEnum.SELECT:
					if selected_nodes.size() > 0:
						remove_out_of_bounds()
						drag_start = Vector2.INF
						return
					if drag_start == Vector2.INF:
						return
					$Line.points = []
					var a = drag_start
					var b = event.position
					var mi = Vector2(min(a.x, b.x), min(a.y, b.y))
					var ma = Vector2(max(a.x, b.x), max(a.y, b.y))
					var rect = Rect2(mi, ma - mi)
					
					var persist_nodes = get_tree().get_nodes_in_group("Persist")
					
					var nodes: Array[EditableNode] = []
					
					for node in persist_nodes:
						if node.within_rect(rect):
							nodes.append(node)
					
					proceed_to_edit_nodes(nodes, false)
				_:
					remove_out_of_bounds()
			drag_start = Vector2.INF

func _unhandled_input(event): # TODO: hopefully only use this to deselect, multi-select and place
	if event is InputEventMouseButton:
		if event.pressed && button_pressed == ButtonEnum.NONE:
			proceed_to_edit_nodes([])
			if !GameInfo.editing:
				return
			var pos = event.position
			match current_action:
				ActionEnum.PLACE:
					if !get_viewport_rect().has_point(pos):
						return
					var node = current_object.instantiate()
					node.position = pos
					if "shape_size" in node:
						node.shape_size = Vector2(64, 64)
						node.position -= Vector2(32, 32)
					get_tree().current_scene.add_child(node)
					proceed_to_edit_nodes([node])
					set_mouse_pos(pos)
				ActionEnum.SELECT:
					drag_start = pos
					dragging = true
	elif event is InputEventMouseMotion:
		if dragging && current_action == ActionEnum.SELECT:
			var a = drag_start
			var b = event.position
			var mi = Vector2(min(a.x, b.x), min(a.y, b.y))
			var ma = Vector2(max(a.x, b.x), max(a.y, b.y))
			set_line(Rect2(mi, ma - mi))
			return
		if button_pressed == ButtonEnum.NONE:
			return
		if selected_nodes.size() == 0:
			return
		if mouse_pos == Vector2.INF:
			set_mouse_pos(event.position)
		var diff = event.position - mouse_pos
		match button_pressed:
			ButtonEnum.RESIZE:
				var rect = get_editing_rect()
				var p = og_size + diff
				var a = rect.position.posmodv(grid_size)
				p = ((p + grid_offset + a) / grid_size).round() * grid_size - grid_offset - a
				p = p.clamp(MIN_SIZE, MAX_SIZE).clamp(grid_size, MAX_SIZE)
				
				var size_ratio = p / rect.size
				for node in selected_nodes:
					node.resize(size_ratio)
					var r = node.get_bounding_rect()
					var pos = r.position
					var d = node.position - pos
					pos -= rect.position
					pos *= size_ratio
					node.position = pos + rect.position + d
					node.var_updated()
				reposition_elements()
			ButtonEnum.NODE:
				push_error("This shouldn't happen!!! (ButtonEnum.NODE)")
#				var p = og_pos + diff
#				editing_node.position = ((p + grid_offset) / grid_size).round() * grid_size - grid_offset
#				reposition_elements()

var grid_was_visible = false

func toggle_editor_hide():
	for node in get_tree().get_nodes_in_group("EditorHide"):
		node.visible = !node.visible

func _on_play_button_pressed():
	if GameInfo.editing:
		play()
	else:
		pause()

func play():
	GameInfo.editing = false
	toggle_editor_hide()
	grid_was_visible = $Grid.visible
	$Grid.visible = false
	for child in %PlaceButton.get_children():
		child.queue_free()
	var stuff = LevelSaver.serialize_level()
	GameInfo.current_level = stuff
	get_tree().change_scene_to_packed(preload("res://scenes/BlankPlaytest.tscn"))
	LevelSaver.deserialize_level.call_deferred(stuff)

func pause():
	GameInfo.editing = true
	toggle_editor_hide()
	$Grid.visible = grid_was_visible
	GameInfo.reload_scene()
	set_current_object(current_object)


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if !GameInfo.editing && GameInfo.node_editor != null:
			pause()

func _on_grid_button_pressed():
	if $Grid.visible:
		if grid_size.x > GRID_SMALL.x:
			set_grid_size(GRID_SMALL)
			%GridButton.icon = preload("res://assets/icons/Grid_Small.png")
		else:
			$Grid.visible = false
			set_grid_size(GRID_NONE)
			%GridButton.icon = preload("res://assets/icons/Grid.png")
			%GridButton.modulate.v = 0.3
	else:
		$Grid.visible = true
		set_grid_size(GRID_BIG)
		%GridButton.modulate.v = 1

func _on_edit_button_pressed():
	var editor_scene = preload("res://prefabs/editor/node_values_editor.tscn")
	var editor = editor_scene.instantiate()
	$UI.add_child(editor)
	editor.set_edit_node(selected_nodes[0])


func _on_drag_button_pressed():
	set_action(ActionEnum.DRAG)

func _on_select_button_pressed():
	set_action(ActionEnum.SELECT)

func _on_place_button_pressed():
	set_action(ActionEnum.PLACE)

func set_current_object(a):
	for child in %PlaceButton.get_children():
		child.queue_free()
	var b = a.instantiate()
	b.remove_from_group("Persist")
	b.prepare_as_sample(Vector2(64, 64))
	%PlaceButton.add_child(b)
	current_object = a
	set_action(ActionEnum.PLACE)

func _on_objects_button_pressed():
	var selectScene = preload("res://prefabs/editor/object_select.tscn")
	var select = selectScene.instantiate()
	$UI.add_child(select)
	select.add_object({
		"prefab": preload("res://prefabs/nodes/balls/ball.tscn"),
		"name": "Ball"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/balls/reverse_ball.tscn"),
		"name": "Reverse Ball"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/balls/inanimate_ball.tscn"),
		"name": "Inanimate Ball"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/goal.tscn"),
		"name": "Goal"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/wall.tscn"),
		"name": "Wall"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/water.tscn"),
		"name": "Water"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/slope.tscn"),
		"name": "Slope"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/bouncy.tscn"),
		"name": "Bouncy"
	})
	select.add_object({
		"prefab": preload("res://prefabs/nodes/boost.tscn"),
		"name": "Boost"
	})
	select.selected.connect(set_current_object)


func _on_leave_button_pressed():
	# TODO: Save
	GameInfo.to_main_menu()


func _on_save_button_pressed():
	var dict = LevelSaver.serialize_level()
	LevelSaver.save_to_file(GameInfo.level_name, dict)

func _on_more_button_pressed():
	%SaveDialogue.visible = true

func _on_save_dialogue_exit_gui_input(event:InputEvent):
	if %SaveDialogue.visible == true:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				%SaveDialogue.visible = false

func _on_name_text_changed(new_text:String):
	GameInfo.level_name = new_text


func _on_name_text_submitted(new_text):
	GameInfo.level_name = new_text
	%SaveDialogue.visible = false

var prev_height = 0

func _process(__: float):
	var height = DisplayServer.virtual_keyboard_get_height()
	if height > 0:
		if prev_height <= 0:
			prev_height = %SavePanel.position.y
		%SavePanel.position.y = get_viewport_rect().size.y - height
	elif prev_height > 0:
		%SavePanel.position.y = prev_height
		prev_height = 0
