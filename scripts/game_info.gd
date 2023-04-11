@tool
extends Node

@export var wall_color = Color.from_hsv(0, 1, 0.65)
@export var water_color = Color.from_hsv(0.63, 0.82, 0.89)

@export var ball: Ball
@export var goal: Goal
@export var changing_scene: bool

var editing = true

func change_scene(current: Node2D, to: PackedScene):
	changing_scene = true
	var tween = get_tree().create_tween()
	tween.tween_property(current, "global_position", Vector2(-get_viewport().get_visible_rect().size.x * 1.5, 0), 0.5)
	tween.tween_callback(current.queue_free)
	tween.tween_callback(__into_scene.bind(to))

func __into_scene(to: PackedScene):
	if !to:
		return
	var node = to.instantiate()
	get_tree().root.add_child(node)
	get_tree().current_scene = node
	node.global_position = Vector2(get_viewport().get_visible_rect().size.x * 1.5, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(node, "global_position", Vector2(0, 0), 0.5)
	tween.tween_callback(func(): changing_scene = false)
