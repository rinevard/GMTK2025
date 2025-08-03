extends Node2D

@onready var ui: UI = $UI
@onready var level_handler: LevelHandler = $LevelHandler

func _ready() -> void:
	SaveManager.clear_data()

func _on_ui_reading_finished() -> void:
	level_handler.next_level()

func _on_ui_start_game() -> void:
	level_handler.set_level(1)

func _on_ui_continue_game() -> void:
	level_handler.continue_level()

func _on_ui_end_level() -> void:
	level_handler.end_level()

func _on_ui_pause_level() -> void:
	level_handler.pause_level()
