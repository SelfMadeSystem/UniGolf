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
var current_map: int = 0

static func create(name: String, maps: Array[Dictionary]):
	var pack = MapPack.new()
	pack.name = name
	pack.maps = maps
	return pack

func next_map():
	current_map += 1
	if current_map >= maps.size():
		return null
	return maps[current_map]

func get_map():
	return maps[current_map]

func reset():
	current_map = 0
