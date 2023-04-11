@tool
class_name Goal

extends Area2D

@export var outline = 0.1
@export var outline_color = Color.ORANGE
@export var inner_color = Color.BLACK

@onready var radius = ($CollisionShape2D.shape as CircleShape2D).radius * (1 + outline)

var current_scene: Level

var ball: Ball

func _ready():
	if Engine.is_editor_hint():
		return
	current_scene = get_parent()
	get_parent().remove_child.call_deferred(self)
	if GameInfo.goal:
		GameInfo.goal.get_parent().remove_child.call_deferred(GameInfo.goal)
	GameInfo.goal = self
	GameInfo.add_child.call_deferred(self)

func _draw():
	draw_circle(Vector2.ZERO, radius, outline_color)
	draw_circle(Vector2.ZERO, radius / (1 + outline), inner_color)

func _process(_delta):
	queue_redraw()
	if ball:
		var diff = ball.global_position - global_position
		if diff.length_squared() < ball.limit_radius * ball.limit_radius:
			ball.set_limited()
			ball = null
			await get_tree().create_timer(0.5).timeout
			GameInfo.change_scene(current_scene, current_scene.next_scene)

func _on_body_entered(body):
	if body is Ball:
		ball = body
		ball.calculate_limited(global_position, radius / (1 + outline) * global_scale.x)

func _on_body_exited(body):
	if body is Ball:
		ball = null
