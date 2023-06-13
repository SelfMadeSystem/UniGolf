@tool
class_name MapPack

extends Resource

@export var level_data: String
@export var add_level: bool = false:
	set(val):
		if val:
			maps.append(Marshalls.base64_to_variant(level_data))
			level_data = ''

@export var name: String
@export var maps: Array[Dictionary] = []
var current_index: int = 0

static func create(name: String, maps: Array[Dictionary]):
	var pack = MapPack.new()
	pack.name = name
	pack.maps = maps
	return pack

func next_map():
	current_index += 1
	if current_index >= maps.size():
		return null
	return maps[current_index]

func get_map():
	return maps[current_index]

func reset():
	current_index = 0
