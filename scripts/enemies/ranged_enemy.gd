extends Node2D

@onready var ranged_ai_component: AIComponent = $RangedAIComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var time_scale_component: TimeScaleComponent = $TimeScaleComponent
@onready var ranged_anim_scene: AnimScene = $RangedAnimScene

var speed: float = 400
var shot_gap: float = 2.0
var time_after_last_shot: float = 2.0
var is_shoting: bool = false

# region 旋转
var rotation_smoothness: float = 5.0 # 转向平滑度，越大转向越快
var is_flipped: bool = false
var flip_duration: float = 0.12
var origin_scale: Vector2
# endregion

func _ready() -> void:
	# 保存原始缩放值，用于翻转
	origin_scale = ranged_anim_scene.scale
	
	ranged_anim_scene.play_anim("idle")
	ranged_anim_scene.anim_finished.connect(_on_anim_finished)

func _physics_process(delta: float) -> void:
	# 时间缩放
	delta *= time_scale_component.get_time_scale()
	ranged_anim_scene.set_speed_scale(time_scale_component.get_time_scale())

	var pos_offset = ranged_ai_component.get_target_global_pos() - global_position

	# --- 旋转逻辑 ---
	# 只有在离目标有一定距离时才进行转向，避免在目标点上原地抖动
	var player_offset = PlayerRelatedData.get_player_global_pos() - global_position
	if player_offset.length_squared() > 1.0:
		var angle_to_target = player_offset.angle()
		# 使用lerp_angle平滑地将当前朝向转向目标朝向
		rotation = lerp_angle(rotation, angle_to_target, rotation_smoothness * delta)

	# 检查旋转角度，如果角度太大（头会朝下），则垂直翻转精灵
	var angle_diff = rad_to_deg(angle_difference(rotation, 0))
	if abs(angle_diff) > 90 and not is_flipped:
		var tween = get_tree().create_tween()
		tween.tween_property(ranged_anim_scene, "scale", Vector2(origin_scale.x, -origin_scale.y), flip_duration)
		is_flipped = true
	elif abs(angle_diff) < 90 and is_flipped:
		var tween = get_tree().create_tween()
		tween.tween_property(ranged_anim_scene, "scale", Vector2(origin_scale.x, origin_scale.y), flip_duration)
		is_flipped = false
	# --- 旋转逻辑结束 ---

	time_after_last_shot += delta
	# 移动
	if not is_shoting:
		global_position += speed * delta * pos_offset.normalized()

	# 射击
	if time_after_last_shot >= shot_gap:
		shot(PlayerRelatedData.get_player_global_pos() - global_position)
		time_after_last_shot = 0.0

func _on_health_less_than_zero() -> void:
	die()

@onready var dropped_component: DroppedComponent = $DroppedComponent
func die() -> void:
	ParticleHandler.spawn_particle(ParticleHandler.ParticleType.DIE, global_position)
	dropped_component.random_drop()
	queue_free()

func shot(dir: Vector2) -> void:
	is_shoting = true
	ranged_anim_scene.play_anim("attack")
	ranged_anim_scene.play_anim_after_cur_finished("idle")
	PlayerRelatedData.get_bullet_handler().create_bullet(dir, global_position)

func _on_anim_finished(finished_anim_name: String) -> void:
	if finished_anim_name == "attack":
		is_shoting = false
