@tool
class_name Ball

extends EditableNode

@onready var radius = ($CollisionShape2D.shape as CircleShape2D).radius
@export var outline = 0.8
@export var outline_color = Color.BLACK
@export var inner_color = Color.WHITE

var prev_shoot: Vector2

var me: RigidBody2D

# Draw the ball
func _draw():
	draw_circle(Vector2(0, 5), radius, outline_color)
	draw_circle(Vector2.ZERO, radius, outline_color)
	draw_circle(Vector2.ZERO, radius * outline, inner_color)

@export var ball_speed = 18.0
@export var mouse_limit = 125.0
@export var line_length = 2.0

@onready var starting_position = global_position

var mouse_timer: SceneTreeTimer
var mouse_down = false
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

func get_mouse_strength():
	var mouse_pos = get_local_mouse_position()
	if mouse_pos.length_squared() > mouse_limit * mouse_limit:
		mouse_pos = mouse_pos.normalized() * mouse_limit
	return -mouse_pos

var layer = 0

func _ready():
	me = (self as Node) as RigidBody2D
	if Engine.is_editor_hint():
		return
	damp = me.linear_damp
	if GameInfo.editing || GameInfo.changing_scene:
		me.freeze = true
		$WaterDetector.collision_layer = 0
		$WaterDetector.collision_mask = 0
	
	layer = me.collision_layer
	me.collision_layer = 0
	me.collision_mask = 0
	
	%PrevLine.clear_points()
	%PrevLine.add_point(prev_shoot * line_length)
	%PrevLine.add_point(Vector2.ZERO)
	
	GameInfo.reload.connect(reload)
	GameInfo.start.connect(start)
	GameInfo.unpress.connect(unpress)

func unfreeze():
	me.freeze = false
	$WaterDetector.collision_layer = 2
	$WaterDetector.collision_mask = 2

var reloading = false

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if reloading:
		state.transform.origin = starting_position
		state.linear_velocity = Vector2.ZERO
		reloading = false

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
	
#	if mouse_down && pos != starting_position && (!limited || GameInfo.node_editor != null):
#		GameInfo.queue_reload_level()

func reload():
	var new_me = remake_myself()
	new_me.prev_shoot = prev_shoot
	new_me.mouse_down = true
	new_me.mouse_timer = get_tree().create_timer(0.1)
	get_parent().add_child(new_me)
	get_parent().remove_child(self)
	queue_free()

func start():
	mouse_down = true

func unpress(pos: Vector2):
	mouse_down = false
	me.freeze = false
	var mouse_strength = get_mouse_strength()
	%PrevLine.clear_points()
	prev_shoot = mouse_strength
	me.collision_layer = layer
	me.collision_mask = layer
	if mouse_strength.length_squared() >= 15 * 15:
		me.linear_velocity = get_mouse_strength() * ball_speed

func _process(_delta):
	%ShootLine.clear_points()
#	if !Input.is_mouse_button_pressed(1):
#			mouse_down = false
	if mouse_down && !limited:
		%ShootLine.add_point(get_mouse_strength() * line_length)
		%ShootLine.add_point(Vector2.ZERO)
