extends Area2D

@onready var hitbox: Node2D = $HitBox

@export var type: NodeEditor.ButtonEnum

func _ready():
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

func _on_mouse_entered():
	hitbox.visible = true

func _on_mouse_exited():
	hitbox.visible = false

func _input(event):
	if hitbox.visible:
		GameInfo.node_editor.on_button_input(event, type)
