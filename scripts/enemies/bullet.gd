class_name Bullet
extends Node2D

var speed: float = 1200.0
var dir: Vector2
var life_time: float = 30.0
var is_cold: bool = false

const BULLET = preload("res://scenes/enemies/bullet.tscn")

static func new_bullet(p_dir: Vector2, p_global_pos: Vector2) -> Bullet:
	var bullet = BULLET.instantiate()
	bullet.dir = p_dir.normalized()
	bullet.global_position = p_global_pos
	bullet.look_at(p_global_pos + p_dir.normalized())
	return bullet

func _physics_process(delta: float) -> void:
	if is_cold:
		global_position += 0.5 * speed * delta * dir
	else:
		global_position += speed * delta * dir

	life_time -= delta
	if life_time < 0.0:
		call_deferred("queue_free")

func _on_attack_some_area(area: Area2D) -> void:
	self_destroy()

func self_destroy() -> void:
	call_deferred("queue_free")

func get_cold() -> void:
	is_cold = true
