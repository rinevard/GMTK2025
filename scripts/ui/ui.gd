class_name UI
extends CanvasLayer

signal start_game()
signal end_level()
signal pause_level()
signal continue_game()

@onready var hud: Hud = $HUD
@onready var magic_book: MagicBook = $MagicBook
@onready var start_menu: Control = $StartMenu
@onready var reset_menu: ResetMenu = $ResetMenu

func _ready() -> void:
	hud.hide()
	magic_book.hide()
	reset_menu.hide()
	start_menu.show()
	BgmPlayer.reset_play_menu_bgm()
	PlayerRelatedData.player_lose.connect(_on_player_lose)
	PlayerRelatedData.book_picked.connect(show_magic_book)

func show_magic_book(book_num: int = 1) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	magic_book.set_book(book_num)
	magic_book.show()
	magic_book.jump_out()
	BgmPlayer.low_level_bgm()
	pause_level.emit()

func _on_magic_book_reading_finished() -> void:
	# TODO
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	await magic_book.jump_back()
	PlayerRelatedData.level_continuing.emit()
	magic_book.hide()
	BgmPlayer.ret_level_bgm()
	continue_game.emit()

func _on_start_menu_game_start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	await _transition_fade_in()
	start_game.emit()
	BgmPlayer.reset_play_level_bgm()
	BgmPlayer.stop_menu_bgm()
	start_menu.hide()
	hud.reset_hud()
	hud.show()
	_transition_fade_out()

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
	await reset_menu.jump_back()
	await _transition_fade_in()
	reset_menu.hide()
	magic_book.hide()
	hud.hide()
	end_level.emit()
	BgmPlayer.stop_level_bgm()
	BgmPlayer.reset_play_menu_bgm()
	start_menu.show()
	_transition_fade_out()

func _on_reset_menu_reset_level() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	await reset_menu.jump_back()
	reset_menu.hide()
	hud.reset_hud()
	BgmPlayer.continue_play_level_bgm()
	start_game.emit()

func _on_player_lose() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	reset_menu.show()
	reset_menu.jump_out()
	pause_level.emit()
