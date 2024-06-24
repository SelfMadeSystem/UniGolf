extends Control

signal selected(node: PackedScene)

func add_object(obj: Dictionary): # TODO: Figure out a better way
	var prefab_scene: PackedScene = obj.get("prefab")
	var obj_name: String = obj.get("name")
	var templateScene = preload("res://prefabs/editor/object_template.tscn")
	var template = templateScene.instantiate() as Control
	var prefab = prefab_scene.instantiate()
	prefab.prepare_as_sample(Vector2(template.custom_minimum_size.x, template.custom_minimum_size.x))
	template.add_child(prefab)
	template.get_node("Label").text = obj_name
	template.pressed.connect(func(): 
		selected.emit(prefab_scene)
		queue_free()
	)
	%Objects.add_child(template)

func _on_exit_button_pressed():
	queue_free()
