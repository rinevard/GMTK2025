extends Node

const MAX_PLAYER_HEALTH: int = 3

# 只应由 player 发出
signal player_hurt()

# 由 player_related_data 即本节点发出
signal player_heal()

# 只应由 player 发出
signal player_lose()

# 由 score handler 订阅
signal score_updated()

# 只应由 dropped_book 发出
signal book_picked(idx: int)

var player_global_pos: Vector2 = Vector2(-1000, -1000)
var duplicate_player_global_positions: Dictionary = {}
var bullet_handler: BulletHandler
var enemy_handler: EnemyHandler
var dropped_handler: DroppedHandler
var player_health_component: HealthComponent
var is_drawing: bool = false # 由 pen 设置
var level_score: int = 0
var level_paused: bool = false

# 
signal level_continuing()

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
	player_heal.emit()

## 只应由 level 调用
func update_level(level: Level) -> void:
	bullet_handler = level.bullet_handler
	enemy_handler = level.enemy_handler
	dropped_handler = level.dropped_handler
	
	level_score = 0
	score_updated.emit()

func get_bullet_handler() -> BulletHandler:
	return bullet_handler

func get_enemy_handler() -> EnemyHandler:
	return enemy_handler

func get_dropped_handler() -> DroppedHandler:
	return dropped_handler

## 这可能会返回分身的位置
func get_player_global_pos() -> Vector2:
	if duplicate_player_global_positions.size() > 0:
		return duplicate_player_global_positions.values().back()
	return player_global_pos

func level_get_score(score: int) -> void:
	if score == 0:
		return
	level_score += score
	score_updated.emit()
