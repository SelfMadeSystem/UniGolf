class_name ShapedNode

extends EditableNode

const Shape = ShapeUtils.Shape
const Rotation = ShapeUtils.Rotation

const CIRCLE_SEGMENTS = 32

@export var shape_size: Vector2 = Vector2(64, 64)

@export var shape_shape: Shape = Shape.RECT
# Only visible if shape == Shape.INVERSE_QUARTER_CIRCLE or Shape.RIGHT_TRIANGLE
@export var shape_rotation: Rotation = Rotation.ANGLE_0
# Only visible if shape == QUADRILATERAL
var _quadrilateral_vertex_top = 0.5
@export var quadrilateral_vertex_top: float:
	get:
		return _quadrilateral_vertex_top
	set(value):
		if value == 0 && _quadrilateral_vertex_left == 1 && \
			_quadrilateral_vertex_bottom == 0 && _quadrilateral_vertex_right == 1:
				return
		if value == 1 && _quadrilateral_vertex_left == 0 && \
			_quadrilateral_vertex_bottom == 1 && _quadrilateral_vertex_right == 0:
				return
		_quadrilateral_vertex_top = value
# Only visible if shape == QUADRILATERAL
var _quadrilateral_vertex_right = 0.5
@export var quadrilateral_vertex_right: float:
	get:
		return _quadrilateral_vertex_right
	set(value):
		if quadrilateral_vertex_top == 0 && _quadrilateral_vertex_left == 1 && \
			_quadrilateral_vertex_bottom == 0 && value == 1:
				return
		if quadrilateral_vertex_top == 1 && _quadrilateral_vertex_left == 0 && \
			_quadrilateral_vertex_bottom == 1 && value == 0:
				return
		_quadrilateral_vertex_right = value
# Only visible if shape == QUADRILATERAL
var _quadrilateral_vertex_bottom = 0.5
@export var quadrilateral_vertex_bottom: float:
	get:
		return _quadrilateral_vertex_bottom
	set(value):
		if quadrilateral_vertex_top == 0 && _quadrilateral_vertex_left == 1 && \
			value == 0 && _quadrilateral_vertex_right == 1:
				return
		if quadrilateral_vertex_top == 1 && _quadrilateral_vertex_left == 0 && \
			value == 1 && _quadrilateral_vertex_right == 0:
				return
		_quadrilateral_vertex_bottom = value
# Only visible if shape == QUADRILATERAL
var _quadrilateral_vertex_left = 0.5
@export var quadrilateral_vertex_left: float:
	get:
		return _quadrilateral_vertex_left
	set(value):
		if quadrilateral_vertex_top == 0 && value == 1 && \
			_quadrilateral_vertex_bottom == 0 && _quadrilateral_vertex_right == 1:
				return
		if quadrilateral_vertex_top == 1 && value == 0 && \
			_quadrilateral_vertex_bottom == 1 && _quadrilateral_vertex_right == 0:
				return
		_quadrilateral_vertex_left = value
# Only visible if shape == QUARTER_ARC
var _quarter_arc_inner_x = 0.5
@export var quarter_arc_inner_x: float:
	get:
		return _quarter_arc_inner_x
	set(value):
		if value == 1 && _quarter_arc_inner_y == 1:
			return
		_quarter_arc_inner_x = value
# Only visible if shape == QUARTER_ARC
var _quarter_arc_inner_y = 0.5
@export var quarter_arc_inner_y: float:
	get:
		return _quarter_arc_inner_y
	set(value):
		if value == 1 && _quarter_arc_inner_x == 1:
			return
		_quarter_arc_inner_y = value

# Gets the shape of the node with points between 0 and 1.
# Ignores size and rotation.
func get_relative_shape() -> PackedVector2Array:
	match shape_shape:
		Shape.RECT:
			return ShapeUtils.RECT_SHAPE
		Shape.CIRCLE:
			return ShapeUtils.CIRCLE_SHAPE
		Shape.QUARTER_CIRCLE:
			return ShapeUtils.QUARTER_CIRCLE_SHAPE
		Shape.RIGHT_TRIANGLE:
			return ShapeUtils.RIGHT_TRIANGLE_SHAPE
		Shape.QUADRILATERAL:
			return [
				Vector2(quadrilateral_vertex_top, 0),
				Vector2(1, quadrilateral_vertex_right),
				Vector2(1 - quadrilateral_vertex_bottom, 1),
				Vector2(0, 1 - quadrilateral_vertex_left),
			]
		Shape.QUARTER_ARC:
			var a = ShapeUtils.ARC_SHAPE.duplicate()
			a.append(Vector2(0, 1))
			a.append(Vector2(0, quarter_arc_inner_y))
			var b: PackedVector2Array = ShapeUtils.ARC_SHAPE.duplicate()
			b.reverse()
			b *= Transform2D.IDENTITY.scaled(Vector2(quarter_arc_inner_x, quarter_arc_inner_y))
			a.append_array(b)
			a.append(Vector2(quarter_arc_inner_x, 0))
			a.append(Vector2(1, 0))
			return a
		Shape.INVERSE_QUARTER_CIRCLE:
			return ShapeUtils.INVERSE_QUARTER_CIRCLE_SHAPE
	push_error("Invalid shape")
	return []

func get_rotated_shape(shape: PackedVector2Array) -> PackedVector2Array:
	match shape_rotation:
		Rotation.ANGLE_0:
			return shape
		Rotation.ANGLE_90:
			var new_shape = PackedVector2Array()
			for point in shape:
				new_shape.append(Vector2(point.y, 1 - point.x))
			return new_shape
		Rotation.ANGLE_180:
			var new_shape = PackedVector2Array()
			for point in shape:
				new_shape.append(Vector2(1 - point.x, 1 - point.y))
			return new_shape
		Rotation.ANGLE_270:
			var new_shape = PackedVector2Array()
			for point in shape:
				new_shape.append(Vector2(1 - point.y, point.x))
			return new_shape
	push_error("Invalid rotation")
	return []

func get_shape() -> PackedVector2Array:
	var shape: PackedVector2Array = []

	match shape_shape:
		Shape.RIGHT_TRIANGLE, \
		Shape.INVERSE_QUARTER_CIRCLE, \
		Shape.QUARTER_CIRCLE, \
		Shape.QUARTER_ARC:
			shape = get_rotated_shape(get_relative_shape())
		_:
			shape = get_relative_shape()
	
	var new_shape = PackedVector2Array()
	
	for point in shape:
		new_shape.append(point * shape_size)
	
	return new_shape

func get_shape2d() -> Shape2D:
	match shape_shape:
		Shape.RECT:
			var shape = RectangleShape2D.new()
			shape.extents = shape_size / 2
			return shape
		Shape.INVERSE_QUARTER_CIRCLE, Shape.QUARTER_ARC:
			if GameInfo.editing:
				var shape = ConvexPolygonShape2D.new()
				shape.set_point_cloud(get_shape())
				return shape
			var shape = ConcavePolygonShape2D.new()
			shape.segments = get_shape()
			return shape
		_: # CircleShape2D isn't an ellipse, so we can't use it for the CIRCLE shape
			var shape = ConvexPolygonShape2D.new()
			shape.points = get_shape()
			return shape

func get_shape2d_position() -> Vector2:
	match shape_shape:
		Shape.RECT:
			return shape_size / 2
		_:
			return Vector2(0, 0)


func get_menu_edit_attributes() -> Array:
	var base := EnumAttribute.create(
			"shape_shape",
			self,
			"Shape",
			Shape.keys()
		)
	if !allow_concave_shapes:
		base.values.remove_at(Shape.INVERSE_QUARTER_CIRCLE)
		base.values.remove_at(Shape.QUARTER_ARC)
	match shape_shape:
		Shape.INVERSE_QUARTER_CIRCLE, \
		Shape.QUARTER_CIRCLE, \
		Shape.QUARTER_ARC, \
		Shape.RIGHT_TRIANGLE:
			return [
				base,
				EnumAttribute.create(
					"shape_rotation",
					self,
					"Rotation",
					Rotation.keys()
				)
			]
		_:
			return [
				base
			]

func get_visible_edit_attributes() -> Array:
	match shape_shape:
		Shape.QUADRILATERAL:
			return [
				DragEditAttribute.create(
					"quadrilateral_vertex_top",
					self,
					"quadrilateral_vertex_top",
					Vector2(0, 0),
					Vector2(1, 0),
				),
				DragEditAttribute.create(
					"quadrilateral_vertex_right",
					self,
					"quadrilateral_vertex_right",
					Vector2(1, 0),
					Vector2(1, 1),
				),
				DragEditAttribute.create(
					"quadrilateral_vertex_bottom",
					self,
					"quadrilateral_vertex_bottom",
					Vector2(1, 1),
					Vector2(0, 1),
				),
				DragEditAttribute.create(
					"quadrilateral_vertex_left",
					self,
					"quadrilateral_vertex_left",
					Vector2(0, 1),
					Vector2(0, 0),
				),
			]
		Shape.QUARTER_ARC:
			match shape_rotation:
				Rotation.ANGLE_0:
					return [
						DragEditAttribute.create(
							"quarter_arc_inner_x",
							self,
							"quarter_arc_inner_x",
							Vector2(0, 0),
							Vector2(1, 0),
						),
						DragEditAttribute.create(
							"quarter_arc_inner_y",
							self,
							"quarter_arc_inner_y",
							Vector2(0, 0),
							Vector2(0, 1),
						),
					]
				Rotation.ANGLE_90:
					return [
						DragEditAttribute.create(
							"quarter_arc_inner_x",
							self,
							"quarter_arc_inner_x",
							Vector2(0, 1),
							Vector2(0, 0),
						),
						DragEditAttribute.create(
							"quarter_arc_inner_y",
							self,
							"quarter_arc_inner_y",
							Vector2(0, 1),
							Vector2(1, 1),
						),
					]
				Rotation.ANGLE_180:
					return [
						DragEditAttribute.create(
							"quarter_arc_inner_x",
							self,
							"quarter_arc_inner_x",
							Vector2(1, 1),
							Vector2(0, 1),
						),
						DragEditAttribute.create(
							"quarter_arc_inner_y",
							self,
							"quarter_arc_inner_y",
							Vector2(1, 1),
							Vector2(1, 0),
						),
					]
				Rotation.ANGLE_270:
					return [
						DragEditAttribute.create(
							"quarter_arc_inner_x",
							self,
							"quarter_arc_inner_x",
							Vector2(1, 0),
							Vector2(1, 1),
						),
						DragEditAttribute.create(
							"quarter_arc_inner_y",
							self,
							"quarter_arc_inner_y",
							Vector2(1, 0),
							Vector2(0, 0),
						),
					]
	return []

func get_savable_attributes() -> Array:
	var attrs = super.get_savable_attributes()
	attrs.append_array([
		BaseEditAttribute.create_base("shape_size", self, "shape_size")
	])
	return attrs

@export var allow_concave_shapes := true

@onready var hitbox: CollisionShape2D = $HitBox # Must be present on all inherited dudes

@export var update_hitbox_: bool = false:
	set(_v):
		update_hitbox()

func update_hitbox():
	if hitbox == null:
		return
	hitbox.shape = get_shape2d()
	hitbox.position = get_shape2d_position()
	queue_redraw()

func var_updated():
	update_hitbox()

func contains_point(point: Vector2):
	var shape = get_shape()
	return Geometry2D.is_point_in_polygon(point, shape)

func within_rect(rect: Rect2):
	return rect.has_point(global_position + shape_size / 2)

func _ready():
	super._ready()
	update_hitbox()


func get_bounding_rect() -> Rect2:
	return Rect2(position, shape_size)

func prepare_as_sample(size: Vector2):
	position = Vector2(8, 8)
	shape_size = size - position * 2


func resize(ratio: Vector2):
	shape_size *= ratio


func rotate_ccw(rect: Rect2): # !!! IMPORTANT: CALL super. *AFTER* BECAUSE OVERRODE CHANGES WON'T UPDATE OTHERWISE
	match shape_shape:
		Shape.INVERSE_QUARTER_CIRCLE, \
		Shape.QUARTER_CIRCLE, \
		Shape.QUARTER_ARC, \
		Shape.RIGHT_TRIANGLE:
			shape_rotation = (shape_rotation + 1) % Rotation.size()
		Shape.QUADRILATERAL:
			var temp = quadrilateral_vertex_bottom
			quadrilateral_vertex_bottom = quadrilateral_vertex_left
			quadrilateral_vertex_left = quadrilateral_vertex_top
			quadrilateral_vertex_top = quadrilateral_vertex_right
			quadrilateral_vertex_right = temp
	var prev_size = shape_size
	shape_size = Vector2(prev_size.y, prev_size.x)
	
	var pos_tl = position + Vector2(prev_size.x, 0)
	var rect_tl = rect.position + Vector2(rect.size.x, 0)
	
	var diff = pos_tl - rect_tl
	
	position = rect.position + Vector2(diff.y, -diff.x)
	
	var_updated() # This is why
	should_update_stuff.emit()

# Rotating clockwise is just rotating counter-clockwise 3 times.
# But we need to make sure that the rect we pass in the second time is also
# rotated.
func rotate_cw(rect: Rect2):
	rotate_ccw(rect) # first, normal rotation
	var rotated_rect = Rect2(rect.position, Vector2(rect.size.y, rect.size.x))
	rotate_ccw(rotated_rect) # second, rotated rotation
	rotate_ccw(rect) # third, normal rotation

