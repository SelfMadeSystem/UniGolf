@tool
extends ShapedNode

@export var color: Color = Color(1, 0, 1)

func _draw():
	draw_colored_polygon(get_shape(), color)

var layer: int
var mask: int

var me: StaticBody2D = self as Node as StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	layer = me.collision_layer
	mask =  me.collision_mask
	GameInfo.contact_stuffs.connect(_on_ball_contact_stuffs)
	GameInfo.reload.connect(reload)

func _on_ball_contact_stuffs(stuff: PhysicsDirectBodyState2D, _ball: Ball):
	for i in range(0, stuff.get_contact_count()):
		var obj = stuff.get_contact_collider_object(i)
		if obj == self:
			me.collision_layer = 0
			me.collision_mask = 0
			me.visible = false
			return

func reload():
	me.collision_layer = layer
	me.collision_mask = mask
	me.visible = true
