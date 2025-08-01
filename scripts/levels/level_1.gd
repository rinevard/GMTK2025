extends Level

var spwan_gap: float = 3.0
var time_after_last_spawn: float = 3.0

func _process(delta: float) -> void:
	time_after_last_spawn += delta
	if time_after_last_spawn >= spwan_gap:
		enemy_handler.spawn_enemy()
		time_after_last_spawn = 0.0
