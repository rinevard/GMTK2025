class_name DuplicatePlayer
extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
var need_remove_from_global: bool = false # 防止竞争

const DUPLICATE_PLAYER = preload("res://scenes/player/duplicate_player.tscn")

static func new_duplicate_player(global_pos: Vector2) -> DuplicatePlayer:
	var dup_player: DuplicatePlayer = DUPLICATE_PLAYER.instantiate()
	dup_player.global_position = global_pos
	return dup_player

func _physics_process(delta: float) -> void:
	PlayerRelatedData.update_duplicate_player_pos(get_instance_id(), global_position)
	if need_remove_from_global: # 防止竞争
		PlayerRelatedData.remove_duplicate_player(get_instance_id())


func _on_attacked_area_area_entered(area: Area2D) -> void:
	need_remove_from_global = true
	PlayerRelatedData.remove_duplicate_player(get_instance_id())
	print(str(get_instance_id()) + " die")
	call_deferred("queue_free")
