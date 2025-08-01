class_name EnemyHandler
extends Node2D

@export var spawn_pos: Node2D
const MELEE_ENEMY = preload("res://scenes/enemies/melee_enemy.tscn")

var markers: Array = []

func _ready() -> void:
	markers = spawn_pos.get_children()

func spawn_enemy() -> void:
	var rand_idx = randi_range(0, markers.size() - 1)
	var melee_enemy = MELEE_ENEMY.instantiate()
	melee_enemy.global_position = markers[rand_idx].global_position
	add_child(melee_enemy)
