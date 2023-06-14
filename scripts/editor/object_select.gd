extends Control

signal selected(node: PackedScene)

func add_object(obj: Dictionary):
# Assume obj contains the following:
# prefab: PackedScene
# name: String

# Assume instantiated prefab contains the following:
# position: Vector2
# width: int
# height: int
	var prefabScene: PackedScene = obj.get("prefab")
	var name: String = obj.get("name")
	var templateScene = preload("res://prefabs/editor/object_template.tscn")
	var template = templateScene.instantiate()
	var prefab = prefabScene.instantiate()
	prefab.prepare_as_sample(Vector2(64, 64))
	template.add_child(prefab)
	template.get_node("Label").text = name
	template.pressed.connect(func(): 
		selected.emit(prefabScene)
		queue_free()
	)
	%Objects.add_child(template)

func _on_exit_button_pressed():
	queue_free()
