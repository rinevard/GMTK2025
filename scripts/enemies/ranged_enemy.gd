extends Node2D

@onready var ranged_ai_component: AIComponent = $RangedAIComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var time_scale_component: TimeScaleComponent = $TimeScaleComponent

var speed: float = 400
var shot_gap: float = 2.0
var time_after_last_shot: float = 2.0

func _physics_process(delta: float) -> void:
	# 时间缩放
	delta *= time_scale_component.get_time_scale()

	time_after_last_shot += delta
	# 移动
	var pos_offset = (ranged_ai_component.get_target_global_pos() - global_position)
	global_position += speed * delta * pos_offset.normalized()

	# 射击
	if time_after_last_shot >= shot_gap:
		shot(PlayerRelatedData.get_player_global_pos() - global_position)
		time_after_last_shot = 0.0

func _on_health_less_than_zero() -> void:
	die()

func die() -> void:
	queue_free()

func shot(dir: Vector2) -> void:
	PlayerRelatedData.get_bullet_handler().create_bullet(dir, global_position)
