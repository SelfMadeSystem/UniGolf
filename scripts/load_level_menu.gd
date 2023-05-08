extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	for file in DirAccess.get_files_at(LevelSaver.SAVE_DIR):
		if file.ends_with(".json"):
			var button = Button.new()
			var json = JSON.new()
			json.parse(FileAccess.get_file_as_string(LevelSaver.SAVE_DIR + "/" + file))
			button.text = json.data.get("name")
			button.connect("pressed", _on_button_pressed.bind(json))
			$ListOfLevels.add_child(button)

func _on_button_pressed(json):
	GameInfo.change_scene(json.data)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
