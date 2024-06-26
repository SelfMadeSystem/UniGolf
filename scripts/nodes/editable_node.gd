class_name EditableNode

extends Node2D

const DEFAULT_SIZE = Vector2(16, 16)

class BaseEditAttribute:
	var var_name = ""
	var obj: EditableNode = null
	var name = "Unknown"
	
	func set_val(val):
		obj.set(self.var_name, val)
		obj.var_updated()
	
	func get_val():
		return obj.get(self.var_name)
	
	static func create_base(
		var_name: String,
		obj: EditableNode,
		name: String
	):
		var attr = BaseEditAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		return attr



class EditAttribute:
	extends BaseEditAttribute
	
	func add_control_node(parent: Control):
		if self.name.length() > 0:
			var label = Label.new()
			label.text = self.name + ": "
			parent.add_child(label)

class FloatAttribute:
	extends EditAttribute
	
	var min_v = 0.0
	var max_v = 1.0
	var step = 0.1
	var logarithmic = false
	
	func add_control_node(parent: Control):
		super.add_control_node(parent)
		
		var label = Label.new()
		
		label.text = str("%.2f" % self.get_val())
		
		var range_s = HSlider.new()
		range_s.value = self.get_val()
		range_s.min_value = self.min_v
		range_s.max_value = self.max_v
		if self.step > 0:
			range_s.step = self.step
		
		range_s.exp_edit = self.logarithmic
		
		range_s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		range_s.connect("value_changed", func(v):
			self.set_val(v)
			label.text = str("%.2f" % self.get_val())
		)
		
		parent.add_child(range_s)
		parent.add_child(label)
	
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String,
		min_v: float,
		max_v: float,
		step: float = 0,
		logarithmic: bool = false):
		var attr = FloatAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		attr.min_v = min_v
		attr.max_v = max_v
		attr.step = step
		attr.logarithmic = logarithmic
		return attr

class CheckAttribute:
	extends EditAttribute

	func add_control_node(parent: Control):
		super.add_control_node(parent)
		
		var check = CheckBox.new()
		check.button_pressed = self.get_val()
		
		check.connect("toggled", func(v):
			self.set_val(v)
			self.obj.should_update_stuff.emit()
		)
		
		parent.add_child(check)
	
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String):
		var attr = CheckAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		return attr

class ToggleAttribute:
	extends EditAttribute

	func add_control_node(parent: Control):
		super.add_control_node(parent)
		
		var toggle = CheckButton.new()
		toggle.button_pressed = self.get_val()
		
		toggle.connect("toggled", func(v):
			self.set_val(v)
			self.obj.should_update_stuff.emit()
		)
		
		parent.add_child(toggle)
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String):
		var attr = ToggleAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		return attr

class EnumAttribute:
	extends EditAttribute
	
	var values: PackedStringArray
	
	func add_control_node(parent: Control):
		super.add_control_node(parent)
		
		var options = OptionButton.new()
		for v in self.values:
			options.add_item(v)
		
		options.selected = self.get_val()
		
		options.connect("item_selected", func(v):
			self.set_val(v)
			self.obj.should_update_stuff.emit()
		)
		
		parent.add_child(options)
	
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String,
		values: PackedStringArray) -> EnumAttribute:
		var attr = EnumAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		attr.values = values
		return attr



# Like the little draggy thing in the editor. should be blue dot
class DragEditAttribute: # TODO: Have a base for this
	extends BaseEditAttribute
	
	var start: Vector2
	var end: Vector2
	var color: Color
	
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String,
		start: Vector2,
		end: Vector2,
		color: Color = Color.CYAN):
		var attr = DragEditAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		attr.start = start
		attr.end = end
		attr.color = color
		return attr

# Values saved for this node
var saved_values: Dictionary

signal should_update_stuff

func remake_myself():
	var new_me = LevelSaver.deserialize_node(saved_values)
	return new_me

func get_menu_edit_attributes() -> Array:
	return []

func get_visible_edit_attributes() -> Array:
	return []

func get_savable_attributes() -> Array:
	var attrs: Array = get_menu_edit_attributes()
	attrs.append_array(get_visible_edit_attributes())
	attrs.append(BaseEditAttribute.create_base("position", self, "position"))
	return attrs

## Prepares the node to be displayed in the editor as a sample object
func prepare_as_sample(size: Vector2):
	position = size * 0.5

## Return true to have the node editor update the stuffs ^^^
func var_updated():
	pass

func resize(_ratio: Vector2):
	pass

## Returns true if this node contains a point. The point is relative
func contains_point(point: Vector2):
	return Rect2(-DEFAULT_SIZE, DEFAULT_SIZE * 2).has_point(point)

func get_bounding_rect() -> Rect2:
	return Rect2(position - DEFAULT_SIZE, DEFAULT_SIZE * 2)

## Returns true if this node is within a rect. The rect is absolute
func within_rect(rect: Rect2):
	return rect.has_point(global_position)

func _ready():
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

var hovering = false

func _on_mouse_entered():
	hovering = true

func _on_mouse_exited():
	hovering = false

# Default :)
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if hovering && GameInfo.editing && GameInfo.node_editor:
		GameInfo.node_editor.handle_object_input(self, event)
