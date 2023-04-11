extends Node2D

var draw_function: Callable

func _draw():
	if draw_function:
		draw_function.call(self)
