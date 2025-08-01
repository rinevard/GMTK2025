class_name UI
extends CanvasLayer

signal reading_finished()
@onready var magic_book: MagicBook = $MagicBook

func _ready() -> void:
	magic_book.hide()

func show_magic_book(level_num: int) -> void:
	magic_book.show()

func _on_magic_book_reading_finished() -> void:
	magic_book.hide()
	reading_finished.emit()
