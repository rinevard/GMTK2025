class_name Level
extends Node2D

signal level_completed(num: int)

@export var level_num: int
@export var duration: float = 60.0
var level_time: float = 0.0

@onready var player: Player = $Player
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var bullet_handler: BulletHandler = $BulletHandler
@onready var dropped_handler: DroppedHandler = $DroppedHandler

func _ready() -> void:
	PlayerRelatedData.update_level(self)
	level_time = 0.0
