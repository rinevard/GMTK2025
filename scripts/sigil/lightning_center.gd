class_name LightningCenter
extends Node2D

func light_at(point: Vector2) -> void:
	var new_light: LightningLine = LightningLine.new_lightning(global_position, point)
	add_child(new_light)
	new_light.global_position = Vector2.ZERO
	new_light.strike()
