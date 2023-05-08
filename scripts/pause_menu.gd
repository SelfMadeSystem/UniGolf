extends Control




func _on_resume_pressed():
	get_tree().paused = false
	queue_free()


func _on_quit_pressed():
	get_tree().paused = false
	GameInfo.to_main_menu()
	queue_free()
