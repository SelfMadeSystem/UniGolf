@tool
extends Wall

enum Angle { ANGLE_0, ANGLE_90, ANGLE_180, ANGLE_270 }

@export var flipped = Angle.ANGLE_0:
	set(val):
		flipped = val
		reset_hitbox()

func reset_hitbox():
	if !hitbox:
		return
	super()
	match (flipped):
		Angle.ANGLE_90:
			hitbox.scale.x *= -1
		Angle.ANGLE_180:
			hitbox.scale.x *= -1
			hitbox.scale.y *= -1
		Angle.ANGLE_270:
			hitbox.scale.y *= -1

func _draw():
	if Engine.is_editor_hint():
		return
	draw_colored_polygon(
		get_points(),
		GameInfo.wall_color
	)

func get_points():
	return _get_points() * Transform2D.IDENTITY.scaled(8 * hitbox.scale.abs())

func _get_points() -> PackedVector2Array:
	match (flipped):
		Angle.ANGLE_0:
			return [
				Vector2(0, 1),
				Vector2(1, 1),
				Vector2(0, 0),
			]
		Angle.ANGLE_90:
			return [
				Vector2(1, 1),
				Vector2(0, 1),
				Vector2(1, 0),
			]
		Angle.ANGLE_180:
			return [
				Vector2(1, 1),
				Vector2(0, 0),
				Vector2(1, 0),
			]
		Angle.ANGLE_270:
			return [
				Vector2(0, 1),
				Vector2(1, 0),
				Vector2(0, 0),
			]
	return []






