extends Node2D

@onready var melee_ai_component: AIComponent = $MeleeAIComponent
@onready var health_component: HealthComponent = $HealthComponent

var speed: float = 400
var is_cold: bool = false

func _physics_process(delta: float) -> void:
	var pos_offset = (melee_ai_component.get_target_global_pos() - global_position)
	if is_cold:
		global_position += 0.5 * speed * delta * pos_offset.normalized()
	else:
		global_position += speed * delta * pos_offset.normalized()

func _on_health_less_than_zero() -> void:
	queue_free()

func get_cold() -> void:
	is_cold = true
