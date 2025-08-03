class_name Player
extends Node2D

#region 生命
@onready var health_component: HealthComponent = $HealthComponent
var rest_invincible_time: float = 0.0
var max_invincible_time: float = 3.0
#endregion
@onready var collision_shape_2d: CollisionShape2D = $AttackedArea/CollisionShape2D

@onready var anim_player_scene: AnimScene = $PlayerAnimScene
@onready var broom_end_marker: Marker2D = $PlayerAnimScene/Marker2D

#region 移动与飞行
@export_group("飞行参数")
@export var follow_smoothness: float = 15.0 # 移动平滑度，越大越跟手
@export var rotation_smoothness: float = 7.0 # 转向平滑度，越大转向越快

@export_group("悬停效果")
@export var hover_frequency: float = 2.0 # 浮动频率
@export var hover_amplitude: float = 15.0 # 浮动幅度

@export var x_bound: Vector2 = Vector2(-99999, 99999)
@export var y_bound: Vector2 = Vector2(-99999, 99999)

var origin_scale: Vector2
#endregion

func _ready() -> void:
	PlayerRelatedData.init_player_data(self)
	origin_scale = scale

func _physics_process(delta: float) -> void:
	_update_invincible(delta)
	_update_pos_and_anim(delta)
	_update_hover()
	$Label.text = "Health: " + str(health_component.get_health())

func _update_invincible(delta: float) -> void:
	if rest_invincible_time > 0:
		rest_invincible_time -= delta
		self_modulate.g = 0
	else:
		self_modulate.g = 1

var is_flipped: bool = false
var flip_duration: float = 0.2
func _update_pos_and_anim(delta: float) -> void:
	# 平滑移动
	var target_pos = get_global_mouse_position()
	target_pos.x = clamp(target_pos.x, x_bound[0], x_bound[1])
	target_pos.y = clamp(target_pos.y, y_bound[0], y_bound[1])
	var direction_to_target = (target_pos - global_position)
	# 设置动画
	if PlayerRelatedData.is_drawing:
		anim_player_scene.play_anim("draw")
	elif direction_to_target.length() > 1.0:
		anim_player_scene.play_anim("move")
	else:
		anim_player_scene.play_anim("move")
		# 过渡不好做
		# anim_player_scene.play_anim("idle")
	global_position = global_position.lerp(target_pos, follow_smoothness * delta)

	# 适当旋转
	var angle_to_target = direction_to_target.angle()
	# 只有在离鼠标有一定距离时才进行转向，避免在鼠标上原地抖动
	if direction_to_target.length() > 1.0:
		rotation = lerp_angle(rotation, angle_to_target, rotation_smoothness * delta)

	# 视情况翻转 sprite
	var angle_diff = rad_to_deg(angle_difference(rotation, 0))
	# 角度太大头会倒过来, 进行竖直翻转
	# 旋转的时候加个小无敌
	if abs(angle_diff) > 90 and not is_flipped:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(origin_scale.x, -origin_scale.y), flip_duration)
		is_flipped = true

		# 小无敌
		call_deferred("close_collision")
		tween.finished.connect(open_collision)
	elif abs(angle_diff) < 90 and is_flipped:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(origin_scale.x, origin_scale.y), flip_duration)
		is_flipped = false

		# 小无敌
		call_deferred("close_collision")
		tween.finished.connect(open_collision)
	
	PlayerRelatedData.update_player_data(self)

func close_collision() -> void:
	collision_shape_2d.disabled = true

func open_collision() -> void:
	collision_shape_2d.disabled = false

# 悬停/浮动效果
func _update_hover() -> void:
	var time = Time.get_ticks_msec() / 1000.0
	var hover_offset = sin(time * hover_frequency) * hover_amplitude
	anim_player_scene.position.y = hover_offset

func _hit(area: Area2D) -> void:
	if rest_invincible_time > 0:
		return
	health_component.hit(1)
	_be_invincible()

func _be_invincible() -> void:
	rest_invincible_time = max_invincible_time

func _on_health_less_than_zero() -> void:
	PlayerRelatedData.player_lose.emit()
	die()

func die() -> void:
	call_deferred("queue_free")
