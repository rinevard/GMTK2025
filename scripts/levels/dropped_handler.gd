class_name DroppedHandler
extends Node2D


func clear_dropped() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child.has_method("die"):
			child.die()
