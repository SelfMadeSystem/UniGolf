class_name AngledObject

enum Angle { ANGLE_0, ANGLE_90, ANGLE_180, ANGLE_270 }

static func flip_hitbox(hitbox, flipped):
	match (flipped):
		Angle.ANGLE_90:
			hitbox.scale.x *= -1
		Angle.ANGLE_180:
			hitbox.scale.x *= -1
			hitbox.scale.y *= -1
		Angle.ANGLE_270:
			hitbox.scale.y *= -1

static func get_points(flipped, scale):
	return _get_points(flipped) * Transform2D.IDENTITY.scaled(scale.abs())

static func _get_points(flipped) -> PackedVector2Array:
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
