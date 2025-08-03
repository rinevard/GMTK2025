extends Node

var player_global_pos: Vector2 = Vector2(-1000, -1000)
var duplicate_player_global_positions: Dictionary = {}
var bullet_handler: BulletHandler
var player_health_component: HealthComponent
var is_drawing: bool = false # 由 pen 设置

func init_player_data(player: Player) -> void:
	player_global_pos = player.global_position
	player_health_component = player.health_component

## 只应由 player 调用
func update_player_data(player: Player) -> void:
	player_global_pos = player.global_position

## 只应由复制品调用
func update_duplicate_player_pos(duplicate_player_id: int, global_pos: Vector2):
	duplicate_player_global_positions[duplicate_player_id] = global_pos

## 只应由复制品调用
func remove_duplicate_player(duplicate_player_id: int):
	duplicate_player_global_positions.erase(duplicate_player_id)

func heal_player(value: int) -> void:
	player_health_component.heal(value)

## 只应由 level 调用
func update_level(level: Level) -> void:
	bullet_handler = level.bullet_handler

func get_bullet_handler() -> BulletHandler:
	return bullet_handler

## 这可能会返回分身的位置
func get_player_global_pos() -> Vector2:
	if duplicate_player_global_positions.size() > 0:
		return duplicate_player_global_positions.values().back()
	return player_global_pos
