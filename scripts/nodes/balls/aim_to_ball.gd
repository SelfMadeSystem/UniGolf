@tool
extends AimBaseBall

func get_mouse_strength() -> Vector2:
	var mouse_pos = get_local_mouse_position()
	if mouse_pos.length_squared() > mouse_limit * mouse_limit:
		mouse_pos = mouse_pos.normalized() * mouse_limit
	return mouse_pos
