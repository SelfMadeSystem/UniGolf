@tool
extends ShapedNode

func _draw():
	draw_colored_polygon(get_shape(), Color.WHITE)

const Rot = ShapeUtils.Rotation

@export var gravity_direction = Rot.ANGLE_0
@export var grav = 6400
@export var diagonal = false

@export var straight_texture: Texture
@export var diagonal_texture: Texture

func _get_grav_dir() -> Vector2:
	match gravity_direction:
		Rot.ANGLE_0:
			return Vector2.UP
		Rot.ANGLE_90:
			return Vector2.LEFT
		Rot.ANGLE_180:
			return Vector2.DOWN
		Rot.ANGLE_270:
			return Vector2.RIGHT
	return Vector2()

func get_grav_dir() -> Vector2:
	if diagonal:
		return _get_grav_dir().rotated(deg_to_rad(-45))
	else:
		return _get_grav_dir()

func rotate_ccw(rect: Rect2):
	gravity_direction = (gravity_direction + 1) % Rot.size() as Rot
	super.rotate_ccw(rect)

func get_menu_edit_attributes() -> Array:
	var base = super.get_menu_edit_attributes()
	base.append(EnumAttribute.create(
					"gravity_direction",
					self,
					"Direction",
					Rot.keys()
				))
	base.append(ToggleAttribute.create(
					"diagonal",
					self,
					"Diagonal",
				))
	return base

func get_shader_offset():
	return position + shape_size.posmod(64.0) * 0.5

func update_shader():
	var shader = material as ShaderMaterial
	shader.set_shader_parameter("rotation", gravity_direction)
	shader.set_shader_parameter("offset", get_shader_offset())
	if diagonal:
		shader.set_shader_parameter("sprite", diagonal_texture)
	else:
		shader.set_shader_parameter("sprite", straight_texture)


func var_updated():
	super.var_updated()
	update_shader()
	
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	material = material.duplicate(true)
	update_shader()

func _physics_process(delta):
	for body in self.call("get_overlapping_bodies"):
		if body is RigidBody2D:
			body.linear_velocity += get_grav_dir() * grav * delta
