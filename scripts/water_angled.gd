@tool
extends Water

@export var flipped = AngledObject.Angle.ANGLE_0:
	set(val):
		flipped = val
		reset_hitbox()

func reset_hitbox():
	if !hitbox:
		return
	super()
	AngledObject.flip_hitbox(hitbox, flipped)

func _draw():
	if Engine.is_editor_hint():
		return
	draw_colored_polygon(
		AngledObject.get_points(flipped, hitbox.scale),
		GameInfo.water_color
	)






