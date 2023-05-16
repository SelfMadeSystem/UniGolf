extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var maps: Array[Dictionary] = []
	for file in DirAccess.get_files_at(LevelSaver.SAVE_DIR):
		if file.ends_with(".json"):
			var button = Button.new()
			var json = JSON.new()
			json.parse(FileAccess.get_file_as_string(LevelSaver.SAVE_DIR + "/" + file))
			button.text = json.data.get("name")
			maps.append(json.data)
			button.connect("pressed", _on_button_pressed.bind(json))
			$ListOfLevels.add_child(button)
	
	if maps.size() > 0:
		var button = $PlayAll
		var map_pack = MapPack.new("pack", maps)
		button.connect("pressed", _on_map_pressed.bind(map_pack))

func _on_map_pressed(map: MapPack):
	GameInfo.map_pack = map
	GameInfo.change_scene(map.get_map())

func _on_button_pressed(json):
	GameInfo.change_scene(json.data)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
