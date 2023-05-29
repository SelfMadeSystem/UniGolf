class_name EditableNode

extends Node2D

class BaseEditAttribute:
	var var_name = ""
	var obj: EditableNode = null
	var name = "Unknown"
	
	func set_val(val):
		obj.set(self.var_name, val)
		obj.var_updated()
	
	func get_val():
		return obj.get(self.var_name)



class EditAttribute:
	extends BaseEditAttribute
	
	func add_control_node(parent: Control):
		var label = Label.new()
		label.text = self.name

class FloatAttribute:
	extends EditAttribute
	
	var min = 0.0
	var max = 1.0
	var step = 0.1
	
	func add_control_node(parent: Control):
		super.add_control_node(parent)
		
		var range = HSlider.new()
		range.value = self.get_val()
		range.min_value = self.min
		range.max_value = self.max
		range.step = self.step
		
		range.connect("value_changed", self.set_val)
		
		parent.add_child(range)
	
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
		
		options.connect("item_selected", self.set_val)
	
	static func create(
		var_name: String,
		obj: EditableNode,
		name: String,
		values: PackedStringArray):
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



func get_menu_edit_attributes() -> Array[EditAttribute]:
	return []

func get_visible_edit_attributes() -> Array[DragEditAttribute]:
	return []

# Return true to have the node editor update the stuffs ^^^
func var_updated():
	pass

# Returns true if this node contains a point. The point is relative
func contains_point(point: Vector2):
	return false

# Returns true if this node is within a rect. The rect is absolute
func within_rect(rect: Rect2):
	return rect.has_point(global_position)
