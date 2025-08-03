class_name LevelHandler
extends Node2D

signal level_completed(level_num: int)
var cur_level: Level = null
var cur_level_num: int = 0

const LEVEL_1 = preload("res://scenes/level/level_1.tscn")
var levels: Array[PackedScene] = [null, LEVEL_1]

func next_level() -> void:
	set_level(min(cur_level_num + 1, levels.size() - 1))

func set_level(level_num: int) -> void:
	if cur_level:
		# 移除老关卡
		cur_level.call_deferred("queue_free")
	# 添加新关卡
	var level: Level = levels[level_num].instantiate()
	level.level_completed.connect(_on_level_completed)
	add_child(level)
	cur_level = level
	cur_level_num = level_num
	continue_level()

func _on_level_completed(level_num: int) -> void:
	level_completed.emit(level_num)

func pause_level() -> void:
	Engine.time_scale = 0.0

func continue_level() -> void:
	Engine.time_scale = 1.0

func end_level() -> void:
	if cur_level:
		cur_level.call_deferred("queue_free")
	Engine.time_scale = 1.0
