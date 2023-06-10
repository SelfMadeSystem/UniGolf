extends ShapedNode

func _draw():
	draw_colored_polygon(get_shape(), Color(0.01, 0.48, 0.98))

func _on_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent is Ball:
		parent.vanish()
