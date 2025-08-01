extends Node

var player_global_pos: Vector2

## 只应由 player 调用
func update_player_data(player: Player) -> void:
	player_global_pos = player.global_position
