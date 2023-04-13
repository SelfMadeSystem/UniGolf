class_name Level

extends Node2D

@export var next_scene: Dictionary

func end_scene():
	if next_scene:
		GameInfo.change_scene(next_scene)
	else:
		GameInfo.reload_scene()
