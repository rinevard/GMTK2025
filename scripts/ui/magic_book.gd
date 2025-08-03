class_name MagicBook
extends Control

signal reading_finished()

func set_book(book_num: int) -> void:
	pass

func _on_confirm_pressed() -> void:
	reading_finished.emit()
