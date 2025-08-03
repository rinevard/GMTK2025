class_name AnimScene
extends Node2D

signal anim_finished(finished_name: String)

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var anim_names: Array[String] = []

var next_anim: String = ""

func _ready() -> void:
	animation_player.animation_finished.connect(_anim_finished)

func set_speed_scale(speed: float) -> void:
	animation_player.speed_scale = speed

func play_anim(anim_name: String) -> void:
	if not (anim_name in anim_names):
		return
	animation_player.play(anim_name)

func play_anim_after_cur_finished(anim_name: String) -> void:
	next_anim = anim_name

func _anim_finished(finished_anim_name: String) -> void:
	anim_finished.emit(finished_anim_name)
	if next_anim in anim_names:
		play_anim(next_anim)
	next_anim = ""

@export var eyes: Array[Sprite2D] = []
var eye_idx: int = 0
func hit_eye() -> void:
	if eyes.size() > 0:
		eyes[eye_idx % eyes.size()].visible = false
		eye_idx += 1
