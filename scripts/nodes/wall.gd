@tool
extends ShapedNode

func _draw():
	draw_colored_polygon(get_shape(), Color.RED)
