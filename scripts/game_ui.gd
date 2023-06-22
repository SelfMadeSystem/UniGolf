extends Control

func set_ball_count(val, max):
	$BallCount.visible = max > 1
	$BallCount.text = str(val) + "/" + str(max)
