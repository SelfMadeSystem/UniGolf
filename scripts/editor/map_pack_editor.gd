extends Control

@export var map_pack: MapPack

var items: Dictionary

func _ready():
	if map_pack == null:
		map_pack = MapPack.create("", [])
	add_options()
	add_items()
	%Name.text = map_pack.name

func add_options():
	items = LevelSaver.get_saved_levels()
	
	for key in items.keys():
		var lvl = items[key]
		var txt = lvl.get("name", "Unknown")
		
		var i = %Options.item_count
		
		var add_item = func(a):
			if a == i:
				map_pack.maps.append(lvl)
				add_item_ctrl(lvl)
		
		%Options.add_item(txt)
		
		%Options.item_selected.connect(add_item)

func add_items():
	for a in map_pack.maps:
		add_item_ctrl(a)

func add_item_ctrl(a: Dictionary):
	var b = Button.new()
	b.text = a.get("name", "Unknown")
	
	var remove_item = func():
		%Items.remove_child(b)
		map_pack.maps.erase(a)
	
	b.pressed.connect(remove_item)
	%Items.add_child(b)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_save_pack_pressed():
	MapPackSaver.save_to_file(map_pack)


func _on_line_edit_text_changed(new_text):
	map_pack.name = new_text


func _on_copy_data_pressed():
	DisplayServer.clipboard_set(Marshalls.variant_to_base64(map_pack.to_dict()))


func _on_add_all_pressed():
	for item in items.values():
		map_pack.maps.append(item)
		add_item_ctrl(item)


func _on_delete_pack_pressed():
	DirAccess.remove_absolute(MapPackSaver.CUSTOM_DIR + MapPackSaver.sanitize_file_name(map_pack.name))
	GameInfo.to_main_menu()

