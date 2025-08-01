extends Node

var player_global_pos: Vector2
var bullet_handler: BulletHandler

## 只应由 player 调用
func update_player_data(player: Player) -> void:
	player_global_pos = player.global_position

## 只应由 level 调用
func update_level(level: Level) -> void:
	bullet_handler = level.bullet_handler

func get_bullet_handler() -> BulletHandler:
	return bullet_handler
