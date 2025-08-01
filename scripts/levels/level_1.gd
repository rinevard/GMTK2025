extends Node2D

@onready var enemy_handler: EnemyHandler = $EnemyHandler

var spwan_gap: float = 3.0
var time_after_last_spawn: float = 0.0

func _process(delta: float) -> void:
	time_after_last_spawn -= delta
	if time_after_last_spawn <= 0:
		enemy_handler.spawn_enemy()
		time_after_last_spawn = spwan_gap
