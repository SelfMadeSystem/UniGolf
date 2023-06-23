@tool
class_name MapPack

extends Resource

@export var level_data: String
@export var add_level: bool = false:
	set(val):
		if val:
			maps.append(Marshalls.base64_to_variant(level_data))
			level_data = ''

@export var map_pack_data: String
@export var set_this_to_thing: bool = false:
	set(val):
		if val:
			var dict = Marshalls.base64_to_variant(map_pack_data)
			print(dict)
			name = dict.get("name")
			maps = dict.get("maps")
			map_pack_data = ''

@export var name: String
@export var maps: Array = []
var current_index: int = 0

static func create(name: String, maps: Array):
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

func to_dict() -> Dictionary:
	return {
		"name": name,
		"maps": maps
	}

static func from_dict(dic: Dictionary) -> MapPack:
	return create(dic.get("name", "Unknown"), dic.get("maps", []))
