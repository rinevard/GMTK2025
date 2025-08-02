extends Node2D

@onready var ui: UI = $UI
@onready var level_handler: LevelHandler = $LevelHandler

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_level_handler_level_completed(level_num: int) -> void:
	ui.show_magic_book(level_num)

func _on_ui_reading_finished() -> void:
	level_handler.next_level()
