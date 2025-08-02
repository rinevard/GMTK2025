class_name HealthComponent
extends Node2D

signal health_less_than_zero()

@export var health: int = 1

var is_enemy: bool = false
func _ready() -> void:
	is_enemy = get_parent().is_in_group("Enemy")

func heal(value: int) -> void:
	health += value

func hit(damage: int):
	health -= damage
	if is_enemy:
		ParticleHandler.spawn_particle(ParticleHandler.ParticleType.ATTACKED, global_position)
	if health <= 0:
		health_less_than_zero.emit()

func get_health() -> int:
	return health
