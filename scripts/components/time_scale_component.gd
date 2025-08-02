class_name TimeScaleComponent
extends Node2D

var _time_scale: float = 1.0
var cold_scale: float = 0.5
var bullet_time_scale: float = 0.125

func set_time_scale(ts: float):
	_time_scale = ts

func get_cold() -> void:
	_time_scale *= cold_scale

func get_bullet_time() -> void:
	_time_scale *= bullet_time_scale

func remove_cold() -> void:
	_time_scale /= cold_scale

func remove_bullet_time() -> void:
	_time_scale /= bullet_time_scale

func get_time_scale() -> float:
	return _time_scale
