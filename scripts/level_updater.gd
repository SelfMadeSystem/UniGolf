extends Node

const CURRENT_VERSION: int = 1

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
	return new

func update_0_to_1(lvl: Dictionary):
	for node in lvl.get("nodes", []):
		var name = node.get("name", "")
		if name == "res://prefabs/nodes/ball.tscn":
			node["name"] = "res://prefabs/nodes/balls/ball.tscn"
