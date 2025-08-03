class_name HealthComponent
extends Node2D

signal health_minus(value: int)
signal health_less_than_zero()

@export var health: int = 1
@export var hit_particle_pos_markers: Array[Marker2D] = []
@export var score: int = 0
var hit_particle_idx: int = 0

var is_enemy: bool = false
func _ready() -> void:
	is_enemy = get_parent().is_in_group("Enemy")

func heal(value: int) -> void:
	ParticleHandler.spawn_particle(ParticleHandler.ParticleType.HEAL, global_position, self)
	health += value

func hit(damage: int):
	health -= damage
	health_minus.emit(damage)
	if is_enemy:
		var particle_spawn_pos: Vector2 = global_position
		if hit_particle_pos_markers.size() > 0:
			particle_spawn_pos = hit_particle_pos_markers[hit_particle_idx % hit_particle_pos_markers.size()].global_position
			hit_particle_idx += 1
		ParticleHandler.spawn_particle(ParticleHandler.ParticleType.ATTACKED, particle_spawn_pos)
	if health <= 0:
		health_less_than_zero.emit()
		PlayerRelatedData.level_get_score(score)

func get_health() -> int:
	return health
