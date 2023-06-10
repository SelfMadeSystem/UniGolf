extends ShapedNode

@export var color: Color = Color(0, 1, 0)

func _draw():
	draw_colored_polygon(get_shape(), color)

@export var speed = 2000

var balls: Array[Ball]

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

func _physics_process(delta):
	for ball in balls:
		ball.linear_velocity = ball.linear_velocity.normalized() * speed

func _on_body_entered(body):
	if body is Ball:
		balls.append(body)


func _on_body_exited(body):
	if body is Ball:
		balls.erase(body)
