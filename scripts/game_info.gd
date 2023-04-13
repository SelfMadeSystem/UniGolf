@tool
extends Node

@export var wall_color = Color.from_hsv(0, 1, 0.65)
@export var water_color = Color.from_hsv(0.63, 0.82, 0.89)

@export var ball: Ball
@export var goal: Goal
@export var changing_scene: bool

var current_level: Dictionary = {}
var editing = true

func change_scene(to: Dictionary):
	changing_scene = true
	var tween = get_tree().create_tween()
	var current = get_tree().current_scene
	tween.tween_property(current, "global_position", Vector2(-get_viewport().get_visible_rect().size.x * 1.5, 0), 0.5)
	tween.tween_callback(__into_scene.bind(to))

func __into_scene(to: Dictionary):
	get_tree().change_scene_to_packed(preload("res://scenes/Blank.tscn"))
	current_level = to
	var a = func():
		LevelSaver.deserialize_level(current_level)
		var current = get_tree().current_scene
		current.global_position = Vector2(get_viewport().get_visible_rect().size.x * 1.5, 0)
		var tween = get_tree().create_tween()
		tween.tween_property(current, "global_position", Vector2(0, 0), 0.5)
		tween.tween_callback(func(): changing_scene = false)
	a.call_deferred()

func reload_scene():
	get_tree().change_scene_to_packed(preload("res://scenes/Blank.tscn"))
	var a = func():
		LevelSaver.deserialize_level(current_level)
	a.call_deferred()
