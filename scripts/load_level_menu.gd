extends Control

@export var set_bottom_button = func(button: Button, maps: Array[Dictionary]):
	if maps.size() == 0:
		button.visible = false
		return
	var map_pack = MapPack.new("pack", maps)
	button.connect("pressed", func():
		GameInfo.map_pack = map_pack
		GameInfo.change_scene(map_pack.get_map()))

@export var bottom_pressed = func(): pass

@export var button_pressed = func(json):
	GameInfo.change_scene(json.data)

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
			button.connect("pressed", button_pressed.bind(json))
			$ListOfLevels.add_child(button)
	
	set_bottom_button.call($BottomButton, maps)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_bottom_button_pressed():
	bottom_pressed.call()
