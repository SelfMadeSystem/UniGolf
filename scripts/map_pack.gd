class_name MapPack

extends Resource

var name: String
var maps: Array[Dictionary]
var current_map: int = 0

func _init(name: String, maps: Array[Dictionary]):
	self.name = name
	self.maps = maps

func next_map():
	current_map += 1
	if current_map >= maps.size():
		return null
	return maps[current_map]

func get_map():
	return maps[current_map]

func reset():
	current_map = 0
