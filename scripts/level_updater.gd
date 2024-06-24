extends Node

const CURRENT_VERSION: int = 3

func _ready():
	var old_levels = DirAccess.open("user://levels")
	if old_levels != null:
		move_files("user://levels", LevelSaver.CUSTOM_DIR)
	var old_packs = DirAccess.open("user://map_pack")
	if old_packs != null:
		move_files("user://map_pack", MapPackSaver.CUSTOM_DIR)

func move_files(from: String, to: String):
	var dir = DirAccess.open(from)
	if dir != null:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			dir.rename(from + "/" + file, to + "/" + file)
			file = dir.get_next()
		DirAccess.remove_absolute(from)

## Updates the level information
func update_level(lvl: Dictionary) -> Dictionary:
	var version = 0
	if lvl.has("version"):
		version = lvl["version"]
	if version >= CURRENT_VERSION:
		return lvl
	var new = lvl.duplicate(true)
	new["version"] = version
	if version < 1:
		update_0_to_1(new)
	if version < 2:
		update_1_to_2(new)
	if version < 3:
		update_2_to_3(new)
	return new

## Fixes old ball location
func update_0_to_1(lvl: Dictionary):
	for node in lvl.get("nodes", []):
		var n_name = node.get("name", "")
		if n_name == "res://prefabs/nodes/ball.tscn":
			node["name"] = "res://prefabs/nodes/balls/ball.tscn"

## Removes old "persist" on nodes
func update_1_to_2(lvl: Dictionary):
	for node in lvl.get("nodes", []):
		if node.has("persist"):
			node.erase("persist")

## Fixes old location for a lot of stuff
func update_2_to_3(lvl: Dictionary):
	for node in lvl.get("nodes", []):
		var n_name = node.get("name", "")
		match n_name:
			"res://prefabs/nodes/boost.tscn":
				node["name"] = "res://prefabs/nodes/terrain/boost.tscn"
			"res://prefabs/nodes/slope.tscn":
				node["name"] = "res://prefabs/nodes/terrain/slope.tscn"
			"res://prefabs/nodes/water.tscn":
				node["name"] = "res://prefabs/nodes/terrain/water.tscn"
			"res://prefabs/nodes/bouncy.tscn":
				node["name"] = "res://prefabs/nodes/walls/bouncy.tscn"
			"res://prefabs/nodes/breakable.tscn":
				node["name"] = "res://prefabs/nodes/walls/breakable.tscn"
			"res://prefabs/nodes/toggleable.tscn":
				node["name"] = "res://prefabs/nodes/walls/toggleable.tscn"
			"res://prefabs/nodes/wall.tscn":
				node["name"] = "res://prefabs/nodes/walls/wall.tscn"
