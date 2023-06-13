@tool
extends ShapedNode

@export var color: Color = Color.from_hsv(0, 1, 1)

func _draw():
	draw_colored_polygon(get_shape(), color)

@export var speed = 2000

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	GameInfo.ball.contact_stuffs.connect(_on_ball_contact_stuffs)

func _on_ball_contact_stuffs(stuff: PhysicsDirectBodyState2D):
	for i in range(0, stuff.get_contact_count()):
		var obj = stuff.get_contact_collider_object(i)
		if obj == self:
			if stuff.linear_velocity.length_squared() >= speed * speed:
				return
			var a = func():
				stuff.linear_velocity = stuff.linear_velocity.normalized() * speed
			a.call_deferred()
			return
