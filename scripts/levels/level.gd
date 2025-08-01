class_name Level
extends Node2D

signal level_completed(num: int)

@export var level_num: int
@export var duration: float = 60.0

@onready var player: Player = $Player
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var bullet_handler: Node2D = $BulletHandler

func _ready() -> void:
	# 切换关卡时不重置玩家位置
	if PlayerRelatedData.player_global_pos != Vector2(-1000, -1000):
		player.global_position = PlayerRelatedData.player_global_pos

	PlayerRelatedData.update_level(self)
