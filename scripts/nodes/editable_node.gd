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
	
	var min = 0.0
	var max = 1.0
	var step = 0.1
	
	func add_control_node(parent: Control):
		super.add_control_node(parent)
		
		var label = Label.new()
		
		label.text = str("%.2f" % self.get_val())
		
		var range = HSlider.new()
		range.value = self.get_val()
		range.min_value = self.min
		range.max_value = self.max
		range.step = self.step
		
		range.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		range.connect("value_changed", func(v):
			self.set_val(v)
			label.text = str("%.2f" % self.get_val())
		)
		
		parent.add_child(range)
		parent.add_child(label)
	
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String,
		min: float,
		max: float,
		step: float):
		var attr = FloatAttribute.new()
		attr.var_name = var_name
		attr.obj = obj
		attr.name = name
		attr.min = min
		attr.max = max
		attr.step = step
		return attr

# class CheckAttribute:
# class ToggleAttribute:

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
		)
		
		parent.add_child(options)
	
	func set_val(v):
		super.set_val(v)
		self.obj.should_update_stuff.emit()
	
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

func resize(ratio: Vector2):
	pass

## Returns true if this node contains a point. The point is relative
func contains_point(point: Vector2):
	return Rect2(-DEFAULT_SIZE, DEFAULT_SIZE * 2).has_point(point)

func get_bounding_rect() -> Rect2:
	return Rect2(position - DEFAULT_SIZE, DEFAULT_SIZE * 2)

## Returns true if this node is within a rect. The rect is absolute
func within_rect(rect: Rect2):
	return rect.has_point(global_position)
