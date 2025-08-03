class_name DroppedComponent
extends Node2D

@export var drop_prob: float = 0.1

const DROPPED_BOOK = preload("res://scenes/dropped/dropped_book.tscn")

func random_drop() -> void:
	if randf() > drop_prob:
		return
	var dropped_book = DROPPED_BOOK.instantiate()
	dropped_book.global_position = global_position
	PlayerRelatedData.get_dropped_handler().call_deferred("add_child", dropped_book)
