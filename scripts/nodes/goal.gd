@tool
class_name Goal

extends EditableNode

@export var outline = 0.4
@export var outline_color = Color.ORANGE
@export var inner_color = Color.BLACK

var col_shape: CircleShape2D

func get_radius() -> float:
	return col_shape.radius * (1 + outline)

var balls: Array[Ball]

var col_shape_radius_temp_for_saving

var col_shape_radius:
	get:
		if col_shape == null:
			return null
		return col_shape.radius
	set(value):
		if col_shape == null:
			col_shape_radius_temp_for_saving = value
		else:
			col_shape.radius = value

func _ready():
	if !Engine.is_editor_hint():
		$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	col_shape = $CollisionShape2D.shape as CircleShape2D
	if col_shape_radius_temp_for_saving != null:
		col_shape.radius = col_shape_radius_temp_for_saving

func _draw():
	draw_circle(Vector2.ZERO, get_radius(), outline_color)
	draw_circle(Vector2.ZERO, get_radius() / (1 + outline), inner_color)


func get_savable_attributes() -> Array:
	var attrs = super.get_savable_attributes()
	attrs.append_array([
		BaseEditAttribute.create_base("col_shape_radius", self, "col_shape_radius")
	])
	return attrs

func _process(_delta):
	queue_redraw()
	for ball in balls.duplicate():
		var diff = ball.global_position - global_position
		if diff.length_squared() < col_shape.radius * col_shape.radius:
			ball.set_limited(global_position, col_shape.radius)
			balls.erase(ball)
			GameInfo.start_end_scene()

func _on_body_entered(body):
	if body is Ball:
		balls.append(body)

func _on_body_exited(body):
	if body is Ball:
		balls.erase(body)


func prepare_as_sample(size: Vector2):
	super.prepare_as_sample(size)
	var a = func():
		col_shape.radius *= (0.5 *min(size.x, size.y) - 8) / col_shape.radius
	a.call_deferred()

func resize(ratio: Vector2):
	var r = min(ratio.x, ratio.y)
	var p = col_shape.radius
	col_shape.radius *= r
	var d = col_shape.radius - p
	position += Vector2(d, d)

func get_bounding_rect() -> Rect2:
	return Rect2(position - Vector2(col_shape.radius, col_shape.radius),
		Vector2(col_shape.radius, col_shape.radius) * 2)
