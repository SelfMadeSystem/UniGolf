extends Control

var community_packs: Array[MapPack] = []
var official_packs: Array[MapPack] = []
var challenge_packs: Array[MapPack] = []

func add_local_maps():
	var maps: Array[Dictionary] = []
	for file in DirAccess.get_files_at(LevelSaver.SAVE_DIR):
		if file.ends_with(".json"):
			var json = JSON.new()
			json.parse(FileAccess.get_file_as_string(LevelSaver.SAVE_DIR + "/" + file))
			maps.append(json.data)
	community_packs.insert(0, MapPack.new("Custom", maps))

func create_button(pack: MapPack, container: Control):
	var button = Button.new()
	button.text = pack.name
	button.connect("pressed", _on_button_press.bind(pack))
	container.add_child(button)

func create_buttons(packs: Array[MapPack], container: Control):
	for pack in packs:
		create_button(pack, container)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_local_maps()
	create_buttons(community_packs, $TabContainer/Community)
	create_buttons(official_packs, $TabContainer/Official)
	create_buttons(challenge_packs, $TabContainer/Challenges)


func _on_button_press(pack: MapPack):
	GameInfo.map_pack = pack
	GameInfo.change_scene(pack.get_map())


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
