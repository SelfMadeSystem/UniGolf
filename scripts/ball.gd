@tool
class_name Ball

extends RigidBody2D

@onready var radius = ($CollisionShape2D.shape as CircleShape2D).radius
@export var outline = 0.8
@export var outline_color = Color.BLACK
@export var inner_color = Color.WHITE

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
@onready var damp = linear_damp

var limited = false
var limit_origin = Vector2.ZERO
var limit_radius = -1

func calculate_limited(origin: Vector2, rad: float):
	limit_origin = origin
	limit_radius = rad - 16 * global_scale.x

func set_limited():
	limited = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.from_hsv(0, 0, 0.5), 0.1)

func vanish():
	collision_layer = 0
	collision_mask = 0
	var tween = get_tree().create_tween()
	var speed = 100 / (linear_velocity.length() + 500)
	tween.tween_property(self, "scale", Vector2.ZERO, speed).from_current()
	tween.parallel().tween_property(self, "linear_velocity", Vector2.ZERO, speed).from_current()
	tween.tween_callback(func(): visible = false)

func get_mouse_strength():
	var mouse_pos = get_local_mouse_position()
	if mouse_pos.length_squared() > mouse_limit * mouse_limit:
		mouse_pos = mouse_pos.normalized() * mouse_limit
	return -mouse_pos

func _ready():
	if Engine.is_editor_hint():
		return
	if GameInfo.editing || GameInfo.changing_scene:
		freeze = true
		$WaterDetector.collision_layer = 0
		$WaterDetector.collision_mask = 0
	else:
		freeze = false
		$WaterDetector.collision_layer = 2
		$WaterDetector.collision_mask = 2
		if Input.is_mouse_button_pressed(1):
			mouse_down = true
			mouse_timer = get_tree().create_timer(0.1)
	
	get_parent().remove_child.call_deferred(self)
	if GameInfo.ball:
		GameInfo.ball.get_parent().remove_child.call_deferred(GameInfo.ball)
	GameInfo.ball = self
	GameInfo.add_child.call_deferred(self)

	%PrevLine.add_point(GameInfo.ball_prev_shoot * line_length)
	%PrevLine.add_point(Vector2.ZERO)

func unfreeze():
	freeze = false
	$WaterDetector.collision_layer = 2
	$WaterDetector.collision_mask = 2

func _physics_process(_delta):
	if limited:
		var diff = global_position - limit_origin
		# If outside the limit radius, move back to the limit radius and bounce
		if diff.length_squared() > limit_radius * limit_radius:
			global_position = limit_origin + diff.normalized() * limit_radius
			linear_velocity = linear_velocity.reflect(diff.normalized().orthogonal())
	if mouse_down && global_position != starting_position && !limited:
		GameInfo.reload_scene()
		global_position = starting_position

func _process(_delta):
	%ShootLine.clear_points()
	if !Input.is_mouse_button_pressed(1):
			mouse_down = false
	if mouse_down && !limited:
		%ShootLine.add_point(get_mouse_strength() * line_length)
		%ShootLine.add_point(Vector2.ZERO)

func _unhandled_input(event):
	if !GameInfo.editing && !GameInfo.changing_scene:
		if !limited && event is InputEventMouseButton:
			if event.button_index == 1:
				if event.pressed:
					linear_velocity = Vector2.ZERO
					mouse_timer = get_tree().create_timer(0.1)
				else:
					if mouse_down && mouse_timer.time_left <= 0:
						freeze = false
						var mouse_strength = get_mouse_strength()
						%PrevLine.clear_points()
						GameInfo.ball_prev_shoot = mouse_strength
						if mouse_strength.length_squared() >= 15 * 15:
							linear_velocity += get_mouse_strength() * ball_speed
				mouse_down = event.pressed
