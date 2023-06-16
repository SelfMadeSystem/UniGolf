extends Node

const SAVE_DIR = "user://levels/"
const FILE_EXT = ".ulvl"

func _ready():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func deserialize_level(stuff: Dictionary):
	var nodes: Array = stuff.get("nodes", [])
	var end = Vector2(
		stuff.get("end_pos", Vector2.ZERO),
	)
	
	for a in nodes:
		var node = deserialize_node(a)
		get_tree().current_scene.add_child(node)

func deserialize_node(stuff: Dictionary):
	var scene: PackedScene = load(stuff["name"])
	var node = scene.instantiate()
	
	if stuff.has("pos"):
		node.position = stuff["pos"]
	
	for key in stuff.keys():
		node.set(key, stuff.get(key))
	
	node.saved_values = stuff
	
	return node

func serialize_level():
	var persists = get_tree().get_nodes_in_group("Persist")
	var save_arr = []
	
	for node in persists:
		if node.get_parent() is Control:
			continue
		save_arr.append(get_saved_dict(node))
	
	return {
		"name": GameInfo.level_name,
		"nodes": save_arr,
	}

func get_saved_dict(node: EditableNode):
	var save_dict: Dictionary = {
		"name": node.scene_file_path,
		"pos": node.position
	}
	
	var attrs := node.get_savable_attributes()
	
	for attr in attrs:
		save_dict[attr.var_name] = attr.get_val()
	
	return save_dict

func sanitize_file_name(file_name: String) -> String:
	var sanitized = ""
	
	for c in file_name.to_ascii_buffer():
		if c == 0:
			break
		if c >= 48 && c <= 57 || \
			c >= 65 && c <= 90 || \
			c >= 97 && c <= 122 || \
			c == 95:
			sanitized += String.chr(c)
		else:
			sanitized += "_"
	
	return sanitized + String.num(file_name.hash()) + FILE_EXT

func save_to_file(file_name: String, data: Dictionary):
	file_name = sanitize_file_name(file_name)
	var save_game = FileAccess.open(SAVE_DIR + file_name, FileAccess.WRITE)
	save_game.store_var(data)
	save_game.close()

func load_from_file(file_name: String):
	file_name = sanitize_file_name(file_name)
	if not FileAccess.file_exists(SAVE_DIR + file_name):
		return null
	var save_game = FileAccess.open(SAVE_DIR + file_name, FileAccess.READ)
	
	var variant = save_game.get_var()
	
	save_game.close()

	return variant

func get_saved_levels() -> Dictionary:
	var lvls: Dictionary = {}
	var dir = DirAccess.open(LevelSaver.SAVE_DIR)
	for file_name in dir.get_files():
		if file_name.ends_with(FILE_EXT):
			var file = FileAccess.open(LevelSaver.SAVE_DIR + "/" + file_name, FileAccess.READ)
			var variant = file.get_var()
			lvls[file] = variant
	return lvls
