class_name HealthComponent
extends Node2D

signal health_less_than_zero()

@export var health: int = 1

func hit(damage: int):
	health -= damage
	if health <= 0:
		health_less_than_zero.emit()

func get_health() -> int:
	return health
