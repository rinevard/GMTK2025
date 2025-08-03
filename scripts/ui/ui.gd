class_name UI
extends CanvasLayer

signal start_game()
signal end_level()
signal pause_level()
signal continue_game()

@onready var magic_book: MagicBook = $MagicBook
@onready var start_menu: Control = $StartMenu
@onready var reset_menu: Control = $ResetMenu

func _ready() -> void:
	magic_book.hide()
	reset_menu.hide()
	start_menu.show()
	PlayerRelatedData.player_lose.connect(_on_player_lose)

func show_magic_book(level_num: int=1) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	magic_book.show()
	pause_level.emit()

func _on_magic_book_reading_finished() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	magic_book.hide()
	continue_game.emit()

func _on_start_menu_game_start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	start_game.emit()
	start_menu.hide()

func _on_start_menu_game_end() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await _transition_fade_in()
	get_tree().quit()

@onready var transition_mask: ColorRect = $TransitionMask
var transition_duration: float = 1.0
func _transition_fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(transition_mask, "material:shader_parameter/progress", 1.0, transition_duration)
	await tween.finished

func _transition_fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(transition_mask, "material:shader_parameter/progress", 0.0, transition_duration)
	await tween.finished

func _on_reset_menu_back_to_start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	reset_menu.hide()
	magic_book.hide()
	end_level.emit()
	start_menu.show()

func _on_reset_menu_reset_level() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	reset_menu.hide()
	start_game.emit()

func _on_player_lose() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	reset_menu.show()
	pause_level.emit()
