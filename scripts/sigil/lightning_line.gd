# 文件名: lightning_line.gd
class_name LightningLine
extends Line2D

const LIGHTNING_LINE = preload("res://scenes/sigils/lightning_line.tscn")

static func new_lightning(start: Vector2, end: Vector2) -> LightningLine:
	var lighning_line = LIGHTNING_LINE.instantiate()
	lighning_line.points = PackedVector2Array([
		start, end
	])
	lighning_line.material = lighning_line.material.duplicate()
	return lighning_line

func strike(life_time: float = 0.28):
	# 1. 安全检查和准备
	if not material is ShaderMaterial:
		push_warning("LightningLine has no ShaderMaterial assigned. Cannot perform strike effect.")
		return

	SfxPlayer.play_sfx(SfxPlayer.SFXs.ELEC_ENEMY)
	# 2. 设置动画的初始状态
	# 闪电开始时是完全没有的 (头部和尾部都在起点)
	material.set_shader_parameter("head_progress", 0.0)
	material.set_shader_parameter("tail_progress", 0.0)
	
	# 3. 创建动画序列
	var tween = get_tree().create_tween()

	# 将总时长分成两半：一半用于生长，一半用于收缩
	var grow_duration = life_time * 0.5
	var shrink_duration = life_time * 0.5

	# 动画序列会自动链接执行

	# 阶段1: 生长 (Animate the head)
	# 在 grow_duration 时间内，将 "head_progress" 从 0.0 渐变到 1.0
	# 此时 tail_progress 保持为 0，所以线会变长
	tween.tween_property(
		material, "shader_parameter/head_progress", 1.0, grow_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# 阶段2: 收缩 (Animate the tail)
	# 在 shrink_duration 时间内，将 "tail_progress" 从 0.0 渐变到 1.0
	# 此时 head_progress 保持为 1.0，所以线会从尾部开始缩短
	tween.tween_property(
		material, "shader_parameter/tail_progress", 1.0, shrink_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


func _on_button_pressed() -> void:
	strike()
