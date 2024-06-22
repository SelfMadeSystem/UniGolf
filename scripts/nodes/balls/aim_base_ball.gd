@tool
class_name AimBaseBall

extends Ball

var mouse_down = false
@export var ball_speed = 30.0
@export var mouse_limit = 125.0
@export var line_length = 2.0

var main_ball: bool:
	get:
		return GameInfo.get_main_ball() == self
	set(value):
		if value:
			GameInfo.set_main_ball(self)
		elif main_ball:
			GameInfo.set_main_ball(null)

var prev_shoot: Vector2

func get_mouse_strength() -> Vector2:
	var main_ball = GameInfo.get_main_ball()
	if main_ball == null || main_ball == self:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.length_squared() > mouse_limit * mouse_limit:
			mouse_pos = mouse_pos.normalized() * mouse_limit
		return -mouse_pos
	return main_ball.get_mouse_strength()


func get_menu_edit_attributes() -> Array:
	var base = super.get_menu_edit_attributes()
#	base.append(FloatAttribute.create( # uncertain if good idea
#					"ball_speed",
#					self,
#					"Ball Speed",
#					5.0,
#					50.0,
#					1.0,
#				))
	base.append(ToggleAttribute.create( # uncertain if good idea
					"main_ball",
					self,
					"Main Ball",
				))
	return base

var layer = 0

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
		
	if GameInfo.editing || GameInfo.changing_scene:
		$WaterDetector.collision_layer = 0
		$WaterDetector.collision_mask = 0
	
	layer = me.collision_layer
	if !GameInfo.editing:
		me.collision_layer = 0
		me.collision_mask = 0
	
	%PrevLine.clear_points()
	%PrevLine.add_point(prev_shoot * line_length)
	%PrevLine.add_point(Vector2.ZERO)
	
	GameInfo.unpress.connect(unpress)
	GameInfo.quick_unpress.connect(quick_unpress)

func reload():
	if GameInfo.is_persistant():
		return
	var new_me = remake_myself()
	new_me.prev_shoot = prev_shoot
	new_me.mouse_down = true
	get_parent().add_child(new_me)
	get_parent().remove_child(self)
	queue_free()

func start():
	mouse_down = true


func resize(_ratio: Vector2):
	pass # no resize

func unpress(_pos: Vector2):
	if limited:
		return
	mouse_down = false
	me.freeze = false
	var mouse_strength = get_mouse_strength()
	%PrevLine.clear_points()
	prev_shoot = mouse_strength
	me.collision_layer = layer
	me.collision_mask = layer
	if mouse_strength.length_squared() >= 15 * 15:
		me.linear_velocity = get_mouse_strength() * ball_speed

func quick_unpress():
	mouse_down = false
	%PrevLine.clear_points()

func _process(_delta):
	%ShootLine.clear_points()
#	if !Input.is_mouse_button_pressed(1):
#			mouse_down = false
	if mouse_down && !limited:
		%ShootLine.add_point(get_mouse_strength() * line_length)
		%ShootLine.add_point(Vector2.ZERO)

func get_bounding_rect() -> Rect2:
	var v = Vector2(16, 16)
	return Rect2(position - v, v * 2)
