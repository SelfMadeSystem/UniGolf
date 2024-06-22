@tool
extends Node

## Called before "reload"ing. Cancels reload if bool in passed array is set to false
signal pre_reload(v: Array)

## Reloads the node to its initial state (may not apply if node has persistent attributes; for node to decide)
signal reload

## Called when the user presses on the screen to start the level.
## This is where things like moving platforms should start moving
## Always emitted after reload()
signal start

## Called when the user unpresses from the screen to yeet the ball(s)
signal unpress(pos: Vector2)


## Called when the user unpresses too quickly to yeet the ball(s)
signal quick_unpress


@export var level_name = "Level"

@export var changing_scene: bool

var pause_button: PauseButton

var map_pack: MapPack

var current_level: Dictionary = {}

var level_properties: Dictionary = {}

var editing = false

var node_editor: NodeEditor = null

var current_scene = preload("res://scenes/Blank.tscn")

func pause():
	get_tree().paused = true
	get_tree().root.add_child(
		preload("res://scenes/PauseMenu.tscn").instantiate()
	)

var balls_in_goal = 0

func start_end_scene():
	var min_balls = get_ball_win_count()
	if balls_in_goal >= min_balls:
		return
	set_ball_goal_thing(balls_in_goal + 1)
	if balls_in_goal < min_balls:
		return
	await get_tree().create_timer(0.5).timeout
	end_scene()

func end_scene():
	if map_pack:
		var next = map_pack.next_map()
		if next == null:
			to_main_menu()
		else:
			change_scene(next)
#	else:
#		reload_scene()

func change_scene(to: Dictionary, instant = false):
	changing_scene = true
	if instant:
		__into_scene(to, true)
	else:
		var tween = get_tree().create_tween()
		var current = get_tree().current_scene
		tween.tween_property(current, "global_position", Vector2(-get_viewport().get_visible_rect().size.x * 1.5, 0), 0.5)
		tween.tween_callback(__into_scene.bind(to))

func __into_scene(to: Dictionary, instant = false):
	var new = current_scene.instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.remove_child(get_tree().current_scene)
	get_tree().root.add_child(new)
	get_tree().current_scene = new
	current_level = to
	
	var current = get_tree().current_scene
	print(current)
	if current == null:
		return

	LevelSaver.deserialize_level(current_level)
	
	if !instant:
		current.global_position = Vector2(get_viewport().get_visible_rect().size.x * 1.5, 0)
		var tween = get_tree().create_tween()
		tween.tween_property(current, "global_position", Vector2(0, 0), 0.5)
		tween.tween_callback(func():
			changing_scene = false
			reset_level()
		)
	else:
		changing_scene = false
	
	if node_editor != null:
#			current.add_child(node_editor)
		node_editor.level_loaded()
	GameUi.visible = true

## Just calls the reload function on all the nodes so that persistent nodes stay.
func reload_level():
	if !is_persistant():
		reset_level()
	reload.emit()
	start.emit()

## completely resets the level
func reload_scene():
	var new = current_scene.instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.remove_child(get_tree().current_scene)
	get_tree().root.add_child(new)
	get_tree().current_scene = new
	LevelSaver.deserialize_level(current_level)
	reset_level()

func reset_level():
	set_ball_goal_thing(0)
	switches_for_goal = 0
	switches_for_goal_active = 0

func to_main_menu():
	get_tree().change_scene_to_packed(preload("res://scenes/MainMenu.tscn"))
	for child in get_children():
		child.queue_free()
	
	pause_button = null
	changing_scene = false
	current_level = {}
	level_properties = {}
	main_ball = null
	balls_in_goal = 0
	editing = false
	node_editor = null
	map_pack = null
	switches_for_goal = 0
	switches_for_goal_active = 0
	
	GameUi.visible = false

@onready var timer = get_tree().create_timer(0.1)
var down = false

func _unhandled_input(event):
	if current_level.is_empty():
		return
	if editing:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var arr = [true]
				pre_reload.emit(arr)
				if arr[0]:
					down = true
					reload_level()
					timer = get_tree().create_timer(0.1)
			elif down && timer.time_left <= 0:
				down = false
				unpress.emit(event.global_position)
			else:
				down = false
				quick_unpress.emit()

signal contact_stuffs(stuff: PhysicsDirectBodyState2D, ball: Ball)

func set_ball_goal_thing(i: int):
	GameUi.set_ball_count(i, get_ball_win_count())
	balls_in_goal = i


"""
Switches I guess
"""

var switches_for_goal = 0
var switches_for_goal_active = 0

signal goal_active
signal goal_inactive


"""
Stuff level info
"""
func is_persistant():
	return level_properties.get("persist", false)

func get_ball_win_count():
	return level_properties.get("ball_win_count", 1)

var main_ball: AimBaseBall = null

func get_main_ball() -> AimBaseBall:
	return main_ball

func set_main_ball(ball: AimBaseBall):
	main_ball = ball
