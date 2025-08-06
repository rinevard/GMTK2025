class_name DuplicatePlayer
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

#region 生命
@onready var hitback_sigil_creator: HitbackSigilCreator = $Node/HitbackSigilCreator
@onready var health_component: HealthComponent = $HealthComponent
var rest_invincible_time: float = 0.0
var max_invincible_time: float = 0.2
#endregion

var need_remove_from_global: bool = false # 防止竞争

const DUPLICATE_PLAYER = preload("res://scenes/player/duplicate_player.tscn")

func _ready() -> void:
	sprite_2d.material = sprite_2d.material.duplicate()
	var random_value: float = randf_range(0.0, PI)
	sprite_2d.material.set_shader_parameter("random_offset", random_value)

static func new_duplicate_player(global_pos: Vector2) -> DuplicatePlayer:
	var dup_player: DuplicatePlayer = DUPLICATE_PLAYER.instantiate()
	dup_player.global_position = global_pos
	return dup_player

func _physics_process(delta: float) -> void:
	rest_invincible_time -= delta
	PlayerRelatedData.update_duplicate_player_pos(get_instance_id(), global_position)
	if need_remove_from_global: # 防止竞争
		PlayerRelatedData.remove_duplicate_player(get_instance_id())

func _hit(area: Area2D) -> void:
	if rest_invincible_time > 0:
		return
	health_component.hit(1)
	hitback_sigil_creator.create_hitback_sigil()
	_be_invincible()

func _be_invincible() -> void:
	rest_invincible_time = max_invincible_time

func die() -> void:
	need_remove_from_global = true
	PlayerRelatedData.remove_duplicate_player(get_instance_id())
	visible = false
	call_deferred("_disable_collision")
	get_tree().create_timer(10.0).timeout.connect(_call_deferred_queue_free)

func _disable_collision() -> void:
	$AttackedArea/CollisionShape2D.disabled = true

func _call_deferred_queue_free() -> void:
	call_deferred("queue_free")
