@tool
class_name Ball

extends EditableNode

@onready var radius = ($CollisionShape2D.shape as CircleShape2D).radius
@export var outline = 0.8
@export var outline_color = Color.BLACK
@export var inner_color = Color.WHITE

var me: RigidBody2D

# Draw the ball
func _draw():
	draw_circle(Vector2(0, 5), radius, outline_color)
	draw_circle(Vector2.ZERO, radius, outline_color)
	draw_circle(Vector2.ZERO, radius * outline, inner_color)

@onready var starting_position = global_position

var damp: float

var limited = false
var limit_origin = Vector2.ZERO
var limit_radius = -1

func set_limited(origin: Vector2, rad: float):
	limit_origin = origin
	limit_radius = rad - radius
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
	me = (self as Node) as RigidBody2D
	if Engine.is_editor_hint():
		return
		
	me.freeze = true
	damp = me.linear_damp
	
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
		var diff = pos - limit_origin
		# If outside the limit radius, move back to the limit radius and bounce
		if diff.length_squared() > limit_radius * limit_radius:
			state.transform.origin = limit_origin + diff.normalized() * limit_radius
			state.linear_velocity = state.linear_velocity.reflect(diff.normalized().orthogonal())
			state.linear_velocity *= 0.9
		state.linear_velocity -= diff * 0.05
		state.linear_velocity *= 0.998

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
