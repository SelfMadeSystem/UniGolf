@tool
extends ShapedNode

func _draw():
	draw_colored_polygon(get_shape(), Color.WHITE)

const Rot = ShapeUtils.Rotation

@export var gravity_direction = Rot.ANGLE_0
@export var grav = 3200

func get_grav_dir() -> Vector2:
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

func rotate_ccw(rect: Rect2):
	gravity_direction = (gravity_direction + 1) % Rot.size()
	super.rotate_ccw(rect)

func get_menu_edit_attributes() -> Array:
	var base = super.get_menu_edit_attributes()
	base.append(EnumAttribute.create(
					"gravity_direction",
					self,
					"Direction",
					Rot.keys()
				))
	return base

func var_updated():
	super.var_updated()
	(material as ShaderMaterial).set_shader_parameter("rotation", gravity_direction)

func _ready():
	super._ready()
	material = material.duplicate(true)
	(material as ShaderMaterial).set_shader_parameter("rotation", gravity_direction)

func _physics_process(delta):
	for body in self.call("get_overlapping_bodies"):
		if body is RigidBody2D:
			body.linear_velocity += get_grav_dir() * grav * delta
