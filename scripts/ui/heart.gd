class_name HudHeart

extends TextureRect
@onready var inner_heart: TextureRect = $InnerHeart

var tween_duration: float = 0.3
var is_melt: bool = false

func _ready() -> void:
	inner_heart.material = inner_heart.material.duplicate()

func fade_out() -> void:
	# 使用 Tween 来创建一个平滑的动画
	var tween = create_tween()
	# 在2秒内，将 "dissolve_progress" 参数从0动画到1
	tween.tween_method(
		func(value): 
			if inner_heart.material is ShaderMaterial:
				inner_heart.material.set_shader_parameter("progress", value),
		0.0, # 起始值
		1.0, # 结束值
		tween_duration  # 持续时间（秒）
	).set_trans(Tween.TRANS_SINE) # 使用一个缓动函数让动画更自然
	is_melt = true

func fade_in() -> void:
	# 使用 Tween 来创建一个平滑的动画
	var tween = create_tween()
	# 在2秒内，将 "dissolve_progress" 参数从0动画到1
	tween.tween_method(
		func(value): 
			if inner_heart.material is ShaderMaterial:
				inner_heart.material.set_shader_parameter("progress", value),
		1.0, # 起始值
		0.0, # 结束值
		tween_duration  # 持续时间（秒）
	).set_trans(Tween.TRANS_SINE) # 使用一个缓动函数让动画更自然
	is_melt = false
