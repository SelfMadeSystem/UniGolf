extends Control

@export var default_map: MapPack

# Called when the node enters the scene tree for the first time.
func _ready():
	var lvls = LevelSaver.get_saved_levels()
	for key in lvls.keys():
		var val = lvls.get(key)
		var button = Button.new()
		button.text = val.get("name")
		button.connect("pressed", _on_level_button_pressed.bind(val))
		%ListOfLevels.add_child(button)
	
	var maps = MapPackSaver.get_saved_packs()
	for key in maps.keys():
		var val = maps.get(key)
		var button = Button.new()
		button.text = val.get("name")
		button.connect("pressed", _on_map_button_pressed.bind(val))
		%ListOfPacks.add_child(button)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_level_button_pressed(lvl):
	var level_edit_menu = preload("res://prefabs/level_edit_menu.tscn")
	var inst = level_edit_menu.instantiate()
	inst.lvl = lvl
	inst.level_name = lvl.get("name")
	GameInfo.get_tree().root.add_child(inst)

func _on_new_level_pressed():
	var lvl = default_map.get_map()
	GameInfo.editing = true
	GameInfo.current_scene = preload("res://scenes/BlankEditor.tscn")
	GameInfo.change_scene(lvl, true)
	queue_free()



func _on_map_button_pressed(map: MapPack):
	var srentiernst = preload("res://scenes/MapPackEditor.tscn")
	var thing = srentiernst.instantiate()
	thing.map_pack = map
	get_tree().root.add_child(thing)
	get_tree().current_scene = thing
	queue_free()

func _on_new_pack_pressed():
	get_tree().change_scene_to_file("res://scenes/MapPackEditor.tscn")
