extends Node

const CUSTOM_DIR = "user://custom/map_pack/"
const LOADED_DIR = "user://loaded/map_pack/"
const FILE_EXT = ".upck"

func _ready():
	DirAccess.make_dir_recursive_absolute(CUSTOM_DIR)
	DirAccess.make_dir_recursive_absolute(LOADED_DIR)

func get_dir(loaded: bool = false):
	if loaded:
		return LOADED_DIR
	return CUSTOM_DIR

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

func save_to_file(data: MapPack, loaded = false):
	var file_name = sanitize_file_name(data.name)
	var save_game = FileAccess.open(get_dir(loaded) + file_name, FileAccess.WRITE)
	save_game.store_var(data.to_dict())
	save_game.close()

func load_from_file(file_name: String, loaded = false):
	file_name = sanitize_file_name(file_name)
	if not FileAccess.file_exists(get_dir(loaded) + file_name):
		return null
	var save_game = FileAccess.open(get_dir(loaded) + file_name, FileAccess.READ)
	
	var variant = save_game.get_var()
	
	save_game.close()

	return MapPack.from_dict(variant)

func get_saved_packs(loaded = false) -> Dictionary:
	var lvls: Dictionary = {}
	var dir = DirAccess.open(get_dir(loaded))
	for file_name in dir.get_files():
		if file_name.ends_with(FILE_EXT):
			var file = FileAccess.open(get_dir(loaded) + "/" + file_name, FileAccess.READ)
			var variant = file.get_var()
			lvls[file] = MapPack.from_dict(variant)
	return lvls
