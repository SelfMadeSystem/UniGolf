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

var editing_node: EditableNode # TODO: Make this an array of "selected_nodes"
var menu_edit_attributes: Array[EditableNode.EditAttribute] = []
var visible_edit_attributes: Array[EditableNode.DragEditAttribute] = []
var draggy_thingies: Array[DraggyThingy] = []

func _ready():
	if Engine.is_editor_hint():
		return
	set_grid_size(GRID_BIG)
	GameInfo.current_scene = preload("res://scenes/BlankPlaytest.tscn")
	GameInfo.node_editor = self
	get_parent().remove_child.call_deferred(self)
	GameInfo.add_child.call_deferred(self)
	%Name.text = GameInfo.level_name
	($Grid.material as ShaderMaterial).set_shader_parameter("offset", grid_offset)

func get_editing_rect() -> Rect2:
	return Rect2(editing_node.global_position, editing_node.shape_size).grow(4)

func proceed_to_edit_node(node: Node2D):
	if editing_node:
#		editing_node.input_event.disconnect(_on_editing_node_input_event)
		editing_node.tree_exited.disconnect(deyeet)
	editing_node = node
	if editing_node:
#		editing_node.input_event.connect(_on_editing_node_input_event)
		editing_node.tree_exited.connect(deyeet)
		update_editing_node_attributes()
	reposition_elements()
	mouse_pos = null

func update_editing_node_attributes():
	menu_edit_attributes = editing_node.get_menu_edit_attributes()
	visible_edit_attributes = editing_node.get_visible_edit_attributes()
	for thing in draggy_thingies:
		thing.queue_free()
	draggy_thingies = []
	for attr in visible_edit_attributes:
		var thing = preload("res://prefabs/editor/draggy_thingy.tscn").instantiate()
		thing.attr = attr
		%DraggyThingies.add_child.call_deferred(thing)
		draggy_thingies.append(thing)

func reposition_draggy_thingies():
	for thing in draggy_thingies:
		thing.reposition()

func deyeet():
	editing_node = null
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
	if !editing_node:
		vanish_elements()
		return
	var rect = get_editing_rect()
	var min = Vector2.ONE * 48
	var max = get_viewport_rect().size - min - Vector2.DOWN * 64
	
	var pos = rect.position.clamp(min, max)
	var end = rect.end.clamp(min, max)
	%SelectionBox.position = pos
	%SelectionBox.size = end - pos
	%SelectionBox.selected_nodes.clear()
	%SelectionBox.selected_nodes.append(editing_node)
	%Rotate.visible = editing_node.get("flipped") != null
	set_line(rect)
	reposition_draggy_thingies()

func vanish_elements():
	for thing in draggy_thingies:
		thing.queue_free()
	draggy_thingies = []
	%SelectionBox.position = Vector2.ONE * 69420
	%SelectionBox.selected_nodes.clear()
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
					if editing_node.get("flipped") == null:
						return false
					editing_node.flipped = (editing_node.flipped + 1) % 4
					return true
				ButtonEnum.TRASH:
					editing_node.queue_free()
					editing_node = null
					vanish_elements()
					return true
				ButtonEnum.COPY:
					var clone = editing_node.duplicate()
					editing_node.add_sibling(clone)
					proceed_to_edit_node(clone)
					button_pressed = ButtonEnum.NODE
					return true
	return false

func _on_selection_input(event: InputEvent):
	var mpos = get_viewport().get_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			set_mouse_pos(mpos)
			return true
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT == 0:
			return false
		if editing_node == null:
			return false
		if mouse_pos == null:
			set_mouse_pos(mpos)
		var diff = mpos - mouse_pos
		var p = og_pos + diff
		editing_node.position = ((p + grid_offset) / grid_size).round() * grid_size - grid_offset
		reposition_elements()
		return true

var mouse_pos = Vector2.ZERO
var og_size = Vector2.ZERO
var og_pos = Vector2.ZERO

var drag_start = Vector2.ZERO
var dragging = false

func set_mouse_pos(pos: Vector2):
	mouse_pos = pos
	og_size = editing_node.shape_size
	og_pos = editing_node.position

func _unhandled_input(event): # TODO: hopefully only use this to deselect, multi-select and place
	if event is InputEventMouseButton:
		if !event.pressed:
			button_pressed = ButtonEnum.NONE
			dragging = false
			match current_action:
				ActionEnum.SELECT:
					$Line.points = []
		elif button_pressed == ButtonEnum.NONE:
			proceed_to_edit_node(null)
			if !GameInfo.editing:
				return
			match current_action:
				ActionEnum.PLACE:
					var node = current_object.instantiate()
					node.shape_size = Vector2(64, 64)
					node.position = event.position
					get_tree().current_scene.add_child(node)
					proceed_to_edit_node(node)
					button_pressed = ButtonEnum.NODE
					set_mouse_pos(event.position)
				ActionEnum.SELECT:
					drag_start = event.position
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
		if editing_node == null:
			return
		if mouse_pos == null:
			set_mouse_pos(event.position)
		var diff = event.position - mouse_pos
		match button_pressed:
			ButtonEnum.RESIZE:
				var p = og_size + diff
				var a = editing_node.position.posmodv(grid_size)
				p = ((p + grid_offset + a) / grid_size).round() * grid_size - grid_offset - a
				p = p.clamp(MIN_SIZE, MAX_SIZE)
				editing_node.shape_size = p
				editing_node.var_updated()
				reposition_elements()
			ButtonEnum.NODE:
				var p = og_pos + diff
				editing_node.position = ((p + grid_offset) / grid_size).round() * grid_size - grid_offset
				reposition_elements()

var grid_was_visible = false

func toggle_editor_hide():
	for node in get_tree().get_nodes_in_group("EditorHide"):
		node.visible = !node.visible

func _on_play_button_pressed():
	GameInfo.ball_prev_shoot = Vector2()
	if GameInfo.editing:
		play()
	else:
		pause()

func play():
	GameInfo.editing = false
	toggle_editor_hide()
	grid_was_visible = $Grid.visible
	$Grid.visible = false
	var stuff = LevelSaver.serialize_level()
	GameInfo.current_level = stuff
	get_tree().change_scene_to_packed(preload("res://scenes/BlankPlaytest.tscn"))
	LevelSaver.deserialize_level.bind(stuff).call_deferred()

func pause():
	GameInfo.editing = true
	toggle_editor_hide()
	$Grid.visible = grid_was_visible
	GameInfo.reload_scene()


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


func _on_drag_button_pressed():
	set_action(ActionEnum.DRAG)

func _on_select_button_pressed():
	set_action(ActionEnum.SELECT)

func _on_place_button_pressed():
	set_action(ActionEnum.PLACE)

func _on_objects_button_pressed():
	var selectScene = preload("res://prefabs/editor/object_select.tscn")
	var select = selectScene.instantiate()
	$UI.add_child(select)
	select.add_object({
		"prefab": preload("res://prefabs/nodes/wall.tscn"),
		"name": "Wall"
	})
	select.selected.connect(func(a):
		%PlaceButton.get_child(0).queue_free()
		var b = a.instantiate()
		b.shape_size = Vector2(48, 48)
		b.position = Vector2(8, 8)
		%PlaceButton.add_child(b)
		current_object = a
		set_action(ActionEnum.PLACE)
	)


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

func _on_name_focus_entered():
	if OS.get_name() == "Android" || OS.get_name() == "iOS":
		prev_height = %SavePanel.position.y
		%SavePanel.position.y = 0 #for now. Figure out when to call DisplayServer.virtual_keyboard_get_height()

func _on_name_focus_exited():
	%SavePanel.position.y = prev_height

