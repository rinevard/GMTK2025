class_name EnemyHandler
extends Node2D

@export var spawn_pos: Node2D
const MELEE_ENEMY = preload("res://scenes/enemies/melee_enemy.tscn")
const BIG_MELEE_ENEMY = preload("res://scenes/enemies/big_melee_enemy.tscn")
const RANGED_ENEMY = preload("res://scenes/enemies/ranged_enemy.tscn")
const SPAWN_ENEMY = preload("res://scenes/enemies/spawn_enemy.tscn")
var packed_enemies: Array[PackedScene] = [MELEE_ENEMY, RANGED_ENEMY, BIG_MELEE_ENEMY, SPAWN_ENEMY]

var melee_init_weight: float = 0.4
var ranged_init_weight: float = 0.3
var big_init_weight: float = 0.2
var spawn_init_weight: float = 0.1

var melee_hardest_weight: float = 0.15
var ranged_hardest_weight: float = 0.25
var big_hardest_weight: float = 0.3
var spawn_hardest_weight: float = 0.3

var time_reach_hardest: float = 60.0 * 2

func _spawn_weights() -> Array[float]:
	var hardness = 0.0
	print(hardness)
	if level:
		hardness = level.level_time / time_reach_hardest
	hardness = clamp(hardness, 0.0, 1.0)
	return [lerp(melee_init_weight, melee_hardest_weight, hardness),
	lerp(ranged_init_weight, ranged_hardest_weight, hardness),
	lerp(big_init_weight, big_hardest_weight, hardness),
	lerp(spawn_init_weight, spawn_hardest_weight, hardness)]

var markers: Array = []

var level: Level
func _ready() -> void:
	markers = spawn_pos.get_children()
	var parent = get_parent()
	if parent is Level:
		level = parent

func spawn_enemy(packed_enemy: PackedScene = null, global_pos: Vector2 = Vector2(-10000, -10000)) -> void:
	var spawn_weights: Array[float] = _spawn_weights()
	print(spawn_weights)

	var weights_sum := 0.0
	var rand_idx = 0
	for weight in spawn_weights:
		weights_sum += weight
	
	var remaining_distance := randf() * weights_sum
	print(remaining_distance)
	for i in spawn_weights.size():
		remaining_distance -= spawn_weights[i]
		if remaining_distance < 0:
			rand_idx = i
			break
	print(rand_idx)
	

	var rand_marker = markers.pick_random()
	var rand_packed_enemy = packed_enemies[rand_idx % packed_enemies.size()]
	if packed_enemy:
		rand_packed_enemy = packed_enemy
	var rand_enemy = rand_packed_enemy.instantiate()
	if global_pos != Vector2(-10000, -10000):
		rand_enemy.global_position = global_pos
	else:
		rand_enemy.global_position = rand_marker.global_position
	add_child(rand_enemy)

func clear_enemies() -> void:
	var enemies: Array = get_children()
	for enemy in enemies:
		if enemy.has_method("die"):
			enemy.die()
