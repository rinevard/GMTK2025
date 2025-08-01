class_name Level
extends Node2D

@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var bullet_handler: Node2D = $BulletHandler

func _ready() -> void:
	PlayerRelatedData.update_level(self)
