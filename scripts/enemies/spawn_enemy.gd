extends Node2D

@onready var ranged_ai_component: AIComponent = $RangedAIComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var time_scale_component: TimeScaleComponent = $TimeScaleComponent
@onready var spawn_anim_scene: AnimScene = $SpawnAnimScene
@onready var spawn_pos_marker: Marker2D = $SpawnPosMarker

const MELEE_ENEMY = preload("res://scenes/enemies/melee_enemy.tscn")
const BIG_MELEE_ENEMY = preload("res://scenes/enemies/big_melee_enemy.tscn")
const RANGED_ENEMY = preload("res://scenes/enemies/ranged_enemy.tscn")
var packed_enemies: Array[PackedScene] = [MELEE_ENEMY, MELEE_ENEMY, BIG_MELEE_ENEMY, RANGED_ENEMY]

var speed: float = 200
var spawn_gap: float = 6.5
var max_rand: float = 1.0
var time_after_last_spawn: float = 2.0
var is_spawning: bool = false

func _ready() -> void:
	spawn_gap += randf_range(-max_rand, max_rand)
	spawn_anim_scene.play_anim("idle")
	spawn_anim_scene.anim_finished.connect(_on_anim_finished)

func _physics_process(delta: float) -> void:
	if PlayerRelatedData.level_paused:
		return
	# 时间缩放
	delta *= time_scale_component.get_time_scale()
	spawn_anim_scene.set_speed_scale(time_scale_component.get_time_scale())

	var pos_offset = ranged_ai_component.get_target_global_pos() - global_position

	time_after_last_spawn += delta
	# 移动
	if not is_spawning:
		global_position += speed * delta * pos_offset.normalized()

	# 生孩子
	if time_after_last_spawn >= spawn_gap:
		spawn()
		time_after_last_spawn = 0.0

func _on_health_less_than_zero() -> void:
	die()

@onready var dropped_component: DroppedComponent = $DroppedComponent
func die() -> void:
	ParticleHandler.spawn_particle(ParticleHandler.ParticleType.DIE, global_position)
	dropped_component.random_drop()
	queue_free()

func spawn() -> void:
	is_spawning = true
	spawn_anim_scene.play_anim("create")
	spawn_anim_scene.play_anim_after_cur_finished("idle")
	PlayerRelatedData.get_enemy_handler().spawn_enemy(packed_enemies.pick_random(), spawn_pos_marker.global_position)

func _on_anim_finished(finished_anim_name: String) -> void:
	if finished_anim_name == "create":
		is_spawning = false

func _on_health_component_health_minus(value: int) -> void:
	spawn_anim_scene.hit_eye()
