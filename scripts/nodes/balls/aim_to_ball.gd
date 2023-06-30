@tool
extends AimBaseBall

func get_mouse_strength() -> Vector2:
	return -super.get_mouse_strength()
