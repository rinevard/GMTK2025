extends AIComponent

var threshold: float = 700.0

func get_target_global_pos() -> Vector2:
	if (global_position - PlayerRelatedData.get_player_global_pos()).length() < threshold:
		return global_position
	return PlayerRelatedData.get_player_global_pos()
