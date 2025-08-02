class_name EnemyHandler
extends Node2D

@export var spawn_pos: Node2D
const MELEE_ENEMY = preload("res://scenes/enemies/melee_enemy.tscn")
const QUICK_MELEE_ENEMY = preload("res://scenes/enemies/quick_melee_enemy.tscn")
const RANGED_ENEMY = preload("res://scenes/enemies/ranged_enemy.tscn")
var packed_enemies: Array[PackedScene] = [MELEE_ENEMY, MELEE_ENEMY, QUICK_MELEE_ENEMY, RANGED_ENEMY]

var markers: Array = []

func _ready() -> void:
	markers = spawn_pos.get_children()

func spawn_enemy() -> void:
	var rand_marker = markers.pick_random()
	var rand_packed_enemy = packed_enemies.pick_random()
	var rand_enemy = rand_packed_enemy.instantiate()
	rand_enemy.global_position = rand_marker.global_position
	add_child(rand_enemy)

func clear_enemies() -> void:
	var enemies: Array = get_children()
	for enemy in enemies:
		if enemy.has_method("die"):
			enemy.die()
