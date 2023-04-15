extends Node

func deserialize_level(stuff: Dictionary):
	var nodes: Array = stuff.get("nodes", [])
	var end = Vector2(
		stuff.get("end_x", 0),
		stuff.get("end_y", 0),
	)
	
	GameInfo.goal.position = end
	
	for a in nodes:
		var node = deserialize_node(a)
		get_tree().current_scene.add_child(node)

func deserialize_node(stuff: Dictionary):
	var scene: PackedScene = load(stuff["name"])
	var node = scene.instantiate()
	
	if stuff.has("pos_x"):
		node.position.x = stuff["pos_x"]
	if stuff.has("pos_y"):
		node.position.y = stuff["pos_y"]
	if stuff.has("width"):
		node.width = stuff["width"]
	if stuff.has("height"):
		node.height = stuff["height"]
	if stuff.has("flipped"):
		node.flipped = stuff["flipped"]
	if stuff.has("serialized"):
		node.deserialize(stuff["serialized"])
	
	return node

func serialize_level():
	var persists = get_tree().get_nodes_in_group("Persist")
	var save_arr = []
	
	for node in persists:
		save_arr.append(get_saved_dict(node))
	
	return {
		"nodes": save_arr,
		"end_x": GameInfo.goal.position.x,
		"end_y": GameInfo.goal.position.y
	}

func get_saved_dict(node: Node2D):
	var save_dict: Dictionary = {
		"name": node.scene_file_path,
		"pos_x": node.position.x,
		"pos_y": node.position.y,
	}
	
	var width = node.get("width")
	
	if width != null:
		save_dict["width"] = width
	
	var height = node.get("height")
	
	if height != null:
		save_dict["height"] = height
	
	var flipped = node.get("flipped")
	
	if flipped != null:
		save_dict["flipped"] = flipped
	
	if node.has_method("serialize"):
		save_dict["serialized"] = node.serialize()
	
	return save_dict

