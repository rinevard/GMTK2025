extends Node

# --- 音效资源预加载 ---
const DRAWING_FAIL = preload("res://assets/sfx/drawing_fail.wav")
const DRAWING_LOOP = preload("res://assets/sfx/drawing_loop.wav") # 重要: 请在编辑器的导入设置中将此音效的 Loop Mode 设为 Forward
const DRAWING_SUCCESS = preload("res://assets/sfx/drawing_success.wav")
const ENEMY_DEATH = preload("res://assets/sfx/enemy_death.wav")
const ENEMY_DEATH_2 = preload("res://assets/sfx/enemy_death_2.wav")
const LIGHTNING = preload("res://assets/sfx/lightning.wav")
const PLAYER_HIT = preload("res://assets/sfx/player_hit.wav")
const SIGIL_ACTIVATION_FROST = preload("res://assets/sfx/sigil_activation_frost.wav")
const SIGIL_ACTIVATION_NORMAL = preload("res://assets/sfx/sigil_activation_normal.wav")
const SIGIL_ACTIVATION_SHIELD = preload("res://assets/sfx/sigil_activation_shield.wav")
const ELEC_ENEMY = preload("res://assets/sfx/elec_enemy.ogg")
const HEAL = preload("res://assets/sfx/heal.wav")
const HIT_BACK = preload("res://assets/sfx/hit_back.wav")
const UI_INTRO = preload("res://assets/sfx/ui_intro.wav")
const ICE = preload("res://assets/sfx/ice.wav")

# --- 音效枚举 ---
enum SFXs {
	DRAWING_FAIL,
	# DRAWING_LOOP, # 我们将它从通用列表中移除，因为它有专门的控制方法
	DRAWING_SUCCESS,
	ENEMY_DEATH,
	ENEMY_DEATH_2,
	LIGHTNING,
	PLAYER_HIT,
	SIGIL_ACTIVATION_FROST,
	SIGIL_ACTIVATION_NORMAL,
	SIGIL_ACTIVATION_SHIELD,
	ELEC_ENEMY,
	HEAL,
	HIT_BACK,
	UI_INTRO,
	ICE,
}

# --- 音频播放器 ---
# 用于一次性音效的播放器池
var audio_player_cnt: int = 10
var audio_players: Array[AudioStreamPlayer]

# 新增：专用于播放绘画循环音效的播放器
var draw_loop_player: AudioStreamPlayer

# 将枚举值映射到对应的音效资源
var sfx_map: Dictionary

func _ready() -> void:
	# 初始化映射字典
	# 注意：我们仍然需要 DRAWING_LOOP 在映射中，以便为专用播放器设置 stream
	sfx_map = {
		SFXs.DRAWING_FAIL: DRAWING_FAIL,
		# SFXs.DRAWING_LOOP 不再是通用 SFX 的一部分
		SFXs.DRAWING_SUCCESS: DRAWING_SUCCESS,
		SFXs.ENEMY_DEATH: ENEMY_DEATH,
		SFXs.ENEMY_DEATH_2: ENEMY_DEATH_2,
		SFXs.LIGHTNING: LIGHTNING,
		SFXs.PLAYER_HIT: PLAYER_HIT,
		SFXs.SIGIL_ACTIVATION_FROST: SIGIL_ACTIVATION_FROST,
		SFXs.SIGIL_ACTIVATION_NORMAL: SIGIL_ACTIVATION_NORMAL,
		SFXs.SIGIL_ACTIVATION_SHIELD: SIGIL_ACTIVATION_SHIELD,
		SFXs.ELEC_ENEMY: ELEC_ENEMY,
		SFXs.HEAL: HEAL,
		SFXs.HIT_BACK: HIT_BACK,
		SFXs.UI_INTRO: UI_INTRO,
		SFXs.ICE: ICE,
	}
	
	# --- 初始化专用的绘画循环音效播放器 ---
	draw_loop_player = AudioStreamPlayer.new()
	draw_loop_player.name = "DrawLoopPlayer" # 方便在场景树中调试
	draw_loop_player.stream = DRAWING_LOOP # 直接使用预加载的资源
	# 将播放器设置为总线 "SFX"，如果你的音频总线有不同设置的话
	# draw_loop_player.bus = "SFX" 
	add_child(draw_loop_player)
	
	# --- 创建一次性音效的播放器池 ---
	for i in range(audio_player_cnt):
		var player = AudioStreamPlayer.new()
		add_child(player)
		audio_players.append(player)

# -----------------------------------------------------------------------------
# --- 专用方法：控制绘画循环音效 ---
# -----------------------------------------------------------------------------

## 开始播放绘画循环音效。
## 如果音效已暂停，则会从暂停处继续播放。
## 如果音效已停止，则会从头开始播放。
func play_draw_loop() -> void:
	if draw_loop_player.stream_paused:
		draw_loop_player.stream_paused = false
	# 如果没有在播放（并且也不是暂停状态），则从头播放
	elif not draw_loop_player.is_playing():
		draw_loop_player.play()
## 暂停绘画循环音效。
## 会记住当前播放位置，下次调用 play_draw_loop() 时会从这里继续。
func pause_draw_loop() -> void:
	draw_loop_player.stream_paused = true

## 停止绘画循环音效。
## 会将播放位置重置到开头。
func stop_draw_loop() -> void:
	draw_loop_player.stop()

# -----------------------------------------------------------------------------
# --- 通用方法：播放一次性音效 ---
# -----------------------------------------------------------------------------

## 播放指定的音效
## sfx: 要播放的音效，来自于SFXs枚举
func play_sfx(sfx: SFXs) -> void:
	# 检查传入的sfx是否有效
	if not sfx_map.has(sfx):
		printerr("SFXManager: 尝试播放一个未在sfx_map中定义的音效: ", SFXs.keys()[sfx])
		return

	var sfx_stream = sfx_map[sfx]

	# 遍历播放器池，寻找空闲的播放器
	for player in audio_players:
		if not player.is_playing():
			player.stream = sfx_stream
			player.volume_db = 0.0
			player.play()
			return

	# 如果循环结束后都没有找到空闲播放器，则创建一个新的
	print_debug("SFXManager: 音效池已满，正在创建一个新的AudioStreamPlayer。当前池大小: ", audio_player_cnt)
	
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	audio_players.append(new_player)
	audio_player_cnt += 1
	
	new_player.stream = sfx_stream
	new_player.volume_db = 0.0
	new_player.play()


var mute_db: float = -30.0
func stop_all_sfx() -> void:
	# 停止所有一次性音效
	var tween = get_tree().create_tween()
	var tween_duration: float = 0.3
	var is_any_sfx_playing: bool = false

	for player in audio_players:
		if player.is_playing():
			is_any_sfx_playing = true
			tween.tween_property(player, "volume_db", mute_db, tween_duration)

	# 同时，立即停止循环音效（如果需要的话也可以淡出）
	stop_draw_loop()

	if is_any_sfx_playing:
		await tween.finished

	for player in audio_players:
		player.stop()
		player.volume_db = 0.0
