@tool
extends Node

@export var wall_color = Color.from_hsv(0, 1, 0.65)
@export var water_color = Color.from_hsv(0.63, 0.82, 0.89)

@export var level_name = "Level"

@export var changing_scene: bool

var ball: Ball
var goal: Goal
var pause_button: PauseButton

var ball_prev_shoot: Vector2 = Vector2()

var current_level: Dictionary = {}
var editing = false

var node_editor: NodeEditor = null

var current_scene = preload("res://scenes/Blank.tscn")

func pause():
	get_tree().paused = true
	get_tree().root.add_child(
		preload("res://scenes/PauseMenu.tscn").instantiate()
	)

func change_scene(to: Dictionary):
	ball_prev_shoot = Vector2()
	changing_scene = true
	var tween = get_tree().create_tween()
	var current = get_tree().current_scene
	tween.tween_property(current, "global_position", Vector2(-get_viewport().get_visible_rect().size.x * 1.5, 0), 0.5)
	tween.tween_callback(__into_scene.bind(to))

func __into_scene(to: Dictionary):
	ball_prev_shoot = Vector2()
	get_tree().change_scene_to_packed(current_scene)
	current_level = to
	
	var current_editor = node_editor

	var a = func():
		LevelSaver.deserialize_level(current_level)
		var current = get_tree().current_scene
		current.global_position = Vector2(get_viewport().get_visible_rect().size.x * 1.5, 0)
		var tween = get_tree().create_tween()
		tween.tween_property(current, "global_position", Vector2(0, 0), 0.5)
		tween.tween_callback(func():
			changing_scene = false
			if !editing && ball != null:
				ball.unfreeze()
		)
		
		if current_editor != null:
			current.add_child(current_editor)
			node_editor = current_editor
	a.call_deferred()

func reload_scene():
	print(GameInfo.current_scene)
	get_tree().change_scene_to_packed(current_scene)
	var a = func():
		LevelSaver.deserialize_level(current_level)
	a.call_deferred()

func handle_object_input(object: Node, event: InputEvent):
	if GameInfo.editing && event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			node_editor.proceed_to_edit_node(object)

func to_main_menu():
	get_tree().change_scene_to_packed(preload("res://scenes/MainMenu.tscn"))
	for child in get_children():
		child.queue_free()
	
	ball = null
	goal = null
	pause_button = null
	changing_scene = false
	current_level = {}
	editing = false
	node_editor = null
	ball_prev_shoot = Vector2()
