@tool
class_name Slope
extends Area2D

enum Angle { ANGLE_0, ANGLE_90, ANGLE_180, ANGLE_270 }

@export var flipped = Angle.ANGLE_0:
	set(val):
		flipped = val
		reset_sprite()
@export var width = 64:
	set(val):
		width = val
		reset_sprite()
@export var height = 64:
	set(val):
		height = val
		reset_sprite()

@onready var sprite: Sprite2D = $HitBox/Sprite
@onready var hitbox: Node2D = $HitBox

func reset_sprite():
	grav_dir = Vector2.from_angle(-flipped * PI/2)
	if !sprite || !hitbox:
		return
	sprite.rotation = -flipped * PI/2
	hitbox.scale = Vector2(width, height)
	hitbox.position = hitbox.scale * 0.5

var grav_dir = Vector2.LEFT
@export var grav = 3200

func _ready():
	reset_sprite()


func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			body.linear_velocity += grav_dir * grav * delta

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if GameInfo.editing && event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			NodeEditor.proceed_to_edit_node(self)
