extends Control

signal reset_level()
signal back_to_start()

func _on_reset_button_pressed() -> void:
	reset_level.emit()

func _on_back_start_menu_button_pressed() -> void:
	back_to_start.emit()
