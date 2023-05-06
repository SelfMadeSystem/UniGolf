@tool
class_name Water
extends Area2D

@export var width = 64:
	set(val):
		width = val
		reset_hitbox()
@export var height = 64:
	set(val):
		height = val
		reset_hitbox()

@onready var hitbox: Node2D = $HitBox

func reset_hitbox():
	if !hitbox:
		return
	queue_redraw()
	hitbox.scale = Vector2(width, height)
	hitbox.position = hitbox.scale * 0.5

func _ready():
	reset_hitbox()

var shadow = 0
var outline = 0

func _draw():
	if Engine.is_editor_hint():
		return
	draw_rect(Rect2(0, 0, width, height), GameInfo.water_color)

func _on_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent is Ball:
		parent.vanish()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	GameInfo.handle_object_input(self, event)
