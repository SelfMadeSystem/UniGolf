extends Control

func set_ball_count(val, max_b):
	$BallCount.visible = max_b > 1
	$BallCount.text = str(val) + "/" + str(max_b)
