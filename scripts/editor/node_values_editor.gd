extends Control

func set_edit_node(node: EditableNode):
	add_items(node.get_menu_edit_attributes())
	node.should_update_stuff.connect(func():
		for child in %Objects.get_children():
			child.queue_free()
		add_items(node.get_menu_edit_attributes())
	)

func add_items(items: Array):
	for item in items:
		var n = HFlowContainer.new()
		item.add_control_node(n)
		%Objects.add_child(n)


func _on_exit_button_pressed():
	queue_free()
