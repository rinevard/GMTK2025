class_name EnemyHandler
extends Node2D

@export var spawn_pos: Node2D
const MELEE_ENEMY = preload("res://scenes/enemies/melee_enemy.tscn")
const BIG_MELEE_ENEMY = preload("res://scenes/enemies/big_melee_enemy.tscn")
const RANGED_ENEMY = preload("res://scenes/enemies/ranged_enemy.tscn")
const SPAWN_ENEMY = preload("res://scenes/enemies/spawn_enemy.tscn")
var packed_enemies: Array[PackedScene] = [MELEE_ENEMY, MELEE_ENEMY, BIG_MELEE_ENEMY, RANGED_ENEMY, SPAWN_ENEMY]

var markers: Array = []

func _ready() -> void:
	markers = spawn_pos.get_children()

func spawn_enemy(packed_enemy: PackedScene = null, global_pos: Vector2 = Vector2(-10000, -10000)) -> void:
	var rand_marker = markers.pick_random()
	var rand_packed_enemy = packed_enemies.pick_random()
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
