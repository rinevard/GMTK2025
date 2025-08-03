extends Control

signal game_start()
signal game_end()

func _on_start_button_pressed() -> void:
	game_start.emit()

func _on_exit_button_pressed() -> void:
	game_end.emit()
