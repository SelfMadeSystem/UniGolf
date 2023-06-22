extends Control


func resume():
	get_tree().paused = false
	queue_free()

func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	GameInfo.to_main_menu()
	resume()


func _on_restart_pressed():
	resume()
	GameInfo.reload_scene()
