class_name MagicBook
extends Control

signal reading_finished()

func set_book() -> void:
	pass

func _on_button_pressed() -> void:
	reading_finished.emit()
