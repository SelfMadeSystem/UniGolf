@tool
class_name Ball

extends EditableNode

var col_shape: CircleShape2D

func get_radius() -> float:
	return col_shape.radius

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

func get_savable_attributes() -> Array:
	var attrs = super.get_savable_attributes()
	attrs.append_array([
		BaseEditAttribute.create_base("col_shape_radius", self, "col_shape_radius")
	])
	return attrs



@export var outline = 0.3
@export var shadow = 0.3
@export var outline_color = Color.BLACK
@export var inner_color = Color.WHITE

var me: RigidBody2D

# Draw the ball
func _draw():
	draw_circle(Vector2(0, col_shape.radius * shadow), get_radius(), outline_color)
	draw_circle(Vector2.ZERO, get_radius(), outline_color)
	draw_circle(Vector2.ZERO, get_radius() * (1 - outline), inner_color)

@onready var starting_position = global_position

var damp: float

var limited = false
var limit_origin = Vector2.ZERO
var limit_radius = -1

func set_limited(origin: Vector2, rad: float):
	limit_origin = origin
	limit_radius = rad - get_radius()
	limited = true
	me.set_collision_layer_value(1, false)
	me.set_collision_mask_value(1, false)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.from_hsv(0, 0, 0.5), 0.1)

var tween: Tween

func vanish():
	tween = get_tree().create_tween()
	me.collision_layer = 0
	me.collision_mask = 0
	var speed = 100 / (me.linear_velocity.length() + 500)
	tween.tween_property(self, "scale", Vector2.ZERO, speed).from_current()
	tween.parallel().tween_property(self, "linear_velocity", Vector2.ZERO, speed).from_current()
	tween.tween_callback(func(): visible = false)

func _ready():
	super._ready()
	me = (self as Node) as RigidBody2D
	if Engine.is_editor_hint():
		col_shape = $CollisionShape2D.shape as CircleShape2D
		return
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	col_shape = $CollisionShape2D.shape as CircleShape2D
		
	me.freeze = true
	damp = me.linear_damp
	
	if col_shape_radius_temp_for_saving != null:
		col_shape.radius = col_shape_radius_temp_for_saving
	
	GameInfo.reload.connect(reload)
	GameInfo.start.connect(start)

func unfreeze():
	me.freeze = false
	$WaterDetector.collision_layer = 2
	$WaterDetector.collision_mask = 2

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if state.get_contact_count() > 0:
		GameInfo.contact_stuffs.emit(state, self)
	
	var pos = state.transform.origin
	if limited:
		var ccc = limit_origin + get_parent().global_position
		var diff = pos - ccc
		# If outside the limit radius, move back to the limit radius and bounce
		if diff.length_squared() > limit_radius * limit_radius:
			state.transform.origin = ccc + diff.normalized() * limit_radius
			state.linear_velocity = state.linear_velocity.reflect(diff.normalized().orthogonal())
			state.linear_velocity *= 0.9
		state.linear_velocity -= diff * 0.05
		state.linear_velocity *= 0.998


func resize(ratio: Vector2):
	var r = min(ratio.x, ratio.y)
	var p = col_shape.radius
	col_shape.radius *= r
	var d = col_shape.radius - p
	position += Vector2(d, d)
	queue_redraw()

func get_menu_edit_attributes() -> Array:
	var base = super.get_menu_edit_attributes()
	base.append(FloatAttribute.create(
					"mass",
					self,
					"Mass",
					0.05,
					5.00,
					0.05,
				))
	return base

func reload():
	var new_me = remake_myself()
	get_parent().add_child(new_me)
	get_parent().remove_child(self)
	queue_free()

func start():
	me.freeze = false

func get_bounding_rect() -> Rect2:
	return Rect2(position - Vector2(col_shape.radius, col_shape.radius),
		Vector2(col_shape.radius, col_shape.radius) * 2)
