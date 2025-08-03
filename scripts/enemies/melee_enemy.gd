class_name MeleeEnemy
extends Node2D

@onready var melee_ai_component: AIComponent = $MeleeAIComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var time_scale_component: TimeScaleComponent = $TimeScaleComponent

@export var speed: float = 400
@onready var melee_anim_scene: AnimScene = $MeleeAnimScene

func _ready() -> void:
	melee_anim_scene.play_anim("idle")

func _physics_process(delta: float) -> void:
	# 时间缩放
	delta *= time_scale_component.get_time_scale()
	melee_anim_scene.set_speed_scale(time_scale_component.get_time_scale())
	var pos_offset = (melee_ai_component.get_target_global_pos() - global_position)
	global_position += speed * delta * pos_offset.normalized()

func _on_health_less_than_zero() -> void:
	die()

func die() -> void:
	ParticleHandler.spawn_particle(ParticleHandler.ParticleType.DIE, global_position)
	queue_free()
