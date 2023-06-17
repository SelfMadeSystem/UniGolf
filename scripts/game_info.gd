@tool
extends Node

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


@export var wall_color = Color.from_hsv(0, 1, 0.65)
@export var water_color = Color.from_hsv(0.63, 0.82, 0.89)

@export var level_name = "Level"

@export var changing_scene: bool

var pause_button: PauseButton

var map_pack: MapPack

var current_level: Dictionary = {}
var editing = false

var node_editor: NodeEditor = null

var current_scene = preload("res://scenes/Blank.tscn")

func pause():
	get_tree().paused = true
	get_tree().root.add_child(
		preload("res://scenes/PauseMenu.tscn").instantiate()
	)

var ending_scene = false

func start_end_scene():
	if ending_scene:
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
	get_tree().change_scene_to_packed(current_scene)
	current_level = to
	
	var current_editor = node_editor

	var a = func():
		LevelSaver.deserialize_level(current_level)
		var current = get_tree().current_scene
		
		if !instant:
			current.global_position = Vector2(get_viewport().get_visible_rect().size.x * 1.5, 0)
			var tween = get_tree().create_tween()
			tween.tween_property(current, "global_position", Vector2(0, 0), 0.5)
			tween.tween_callback(func():
				changing_scene = false
			)
		else:
			changing_scene = false
		
		if current_editor != null:
			current.add_child(current_editor)
			node_editor = current_editor
	a.call_deferred()

var reload_level_queued = false

func queue_reload_level():
	if reload_level_queued:
		return
	reload_level_queued = true
	reload_level.call_deferred()

## Just calls the reload function on all the nodes so that persistent nodes stay.
func reload_level():
	reload.emit()
	reload_level_queued = false

## completely resets the level
func reload_scene():
	get_tree().change_scene_to_packed(current_scene)
	var a = func():
		LevelSaver.deserialize_level(current_level)
	a.call_deferred()

func to_main_menu():
	get_tree().change_scene_to_packed(preload("res://scenes/MainMenu.tscn"))
	for child in get_children():
		child.queue_free()
	
	pause_button = null
	changing_scene = false
	current_level = {}
	editing = false
	node_editor = null
	map_pack = null

@onready var timer = get_tree().create_timer(0.1)

func _unhandled_input(event):
	if current_level.is_empty():
		return
	if editing:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				reload.emit()
				start.emit()
				timer = get_tree().create_timer(0.1)
			elif timer.time_left <= 0:
				unpress.emit(event.global_position)
			else:
				quick_unpress.emit()

signal contact_stuffs(stuff: PhysicsDirectBodyState2D, ball: Ball)
