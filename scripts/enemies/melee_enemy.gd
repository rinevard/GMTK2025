extends Node2D

@onready var melee_ai_component: AIComponent = $MeleeAIComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var time_scale_component: TimeScaleComponent = $TimeScaleComponent

var speed: float = 400

func _physics_process(delta: float) -> void:
	# 时间缩放
	delta *= time_scale_component.get_time_scale()

	var pos_offset = (melee_ai_component.get_target_global_pos() - global_position)
	global_position += speed * delta * pos_offset.normalized()

func _on_health_less_than_zero() -> void:
	die()

func die() -> void:
	queue_free()
