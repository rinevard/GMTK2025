class_name Bullet
extends Node2D

var speed: float = 280.0
var dir: Vector2
var life_time: float = 30.0
@onready var time_scale_component: TimeScaleComponent = $TimeScaleComponent

const BULLET = preload("res://scenes/enemies/bullet.tscn")

static func new_bullet(p_dir: Vector2, p_global_pos: Vector2) -> Bullet:
	var bullet = BULLET.instantiate()
	bullet.dir = p_dir.normalized()
	bullet.global_position = p_global_pos
	bullet.look_at(p_global_pos + p_dir.normalized())
	return bullet

@onready var sprite_2d: Sprite2D = $Sprite2D
func _ready() -> void:
	sprite_2d.material = sprite_2d.material.duplicate()

func _physics_process(delta: float) -> void:
	if PlayerRelatedData.level_paused:
		return
	# 时间缩放
	delta *= time_scale_component.get_time_scale()

	global_position += speed * delta * dir

	life_time -= delta
	if life_time < 0.0:
		call_deferred("queue_free")

func _on_attack_some_area(area: Area2D) -> void:
	die()

func die() -> void:
	call_deferred("queue_free")
