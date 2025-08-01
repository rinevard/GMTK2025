extends Node2D

@onready var melee_ai_component: AIComponent = $MeleeAIComponent
@onready var health_component: HealthComponent = $HealthComponent

var speed: float = 400

func _physics_process(delta: float) -> void:
	var pos_offset = (melee_ai_component.get_target_global_pos() - global_position)
	global_position += speed * delta * pos_offset.normalized()

func _on_health_less_than_zero() -> void:
	queue_free()
