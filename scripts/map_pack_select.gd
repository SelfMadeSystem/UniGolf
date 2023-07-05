extends Control

@export var your_packs: Array[MapPack] = []
@export var community_packs: Array[MapPack] = []
@export var official_packs: Array[MapPack] = []
@export var challenge_packs: Array[MapPack] = []

func add_local_maps():
	var maps: Array[Dictionary] = []
	for val in LevelSaver.get_saved_levels().values():
		maps.append(val)
	if maps.size() > 0:
		your_packs.insert(0, MapPack.create("Your Levels", maps))
	
	for val in MapPackSaver.get_saved_packs().values():
		your_packs.insert(1, val)
	
	for val in MapPackSaver.get_saved_packs(true).values():
		community_packs.insert(1, val)

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
	create_buttons(your_packs, $"TabContainer/Your Map Packs/Container")
	create_buttons(community_packs, $TabContainer/Community/Container)
	create_buttons(official_packs, $TabContainer/Official/Container)
	create_buttons(challenge_packs, $TabContainer/Challenges/Container)


func _on_button_press(pack: MapPack):
	GameInfo.map_pack = pack
	GameInfo.change_scene(pack.get_map())


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
