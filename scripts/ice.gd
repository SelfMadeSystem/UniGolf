extends Area2D

func _on_body_entered(body):
	if body is Ball:
		body.linear_damp = linear_damp

func _on_body_exited(body):
	if body is Ball:
		body.linear_damp = body.damp
