extends Node

@onready var levelbgm_player: AudioStreamPlayer = $LevelbgmPlayer
@onready var menubgm_player: AudioStreamPlayer = $MenubgmPlayer

func continue_play_level_bgm() -> void:
	levelbgm_player.stream_paused = false

func pause_level_bgm() -> void:
	levelbgm_player.stream_paused = true


func low_level_bgm() -> void:
	levelbgm_player.volume_db = -15.0

func ret_level_bgm() -> void:
	levelbgm_player.volume_db = 0.0

func reset_play_level_bgm() -> void:
	levelbgm_player.play()

func stop_level_bgm() -> void:
	levelbgm_player.stop()

func reset_play_menu_bgm() -> void:
	menubgm_player.play()

func stop_menu_bgm() -> void:
	menubgm_player.stop()
