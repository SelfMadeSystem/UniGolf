extends ShapedNode

@export var color: Color = Color.from_hsv(0, 1, 0.65)

func _draw():
	draw_colored_polygon(get_shape(), color)
