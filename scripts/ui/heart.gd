class_name HudHeart

extends TextureRect
@onready var inner_heart: TextureRect = $InnerHeart

var tween_duration: float = 0.3
var is_melt: bool = false

# <<< 新增/修改开始 >>>
# 保存心跳动画的 Tween，方便我们随时控制它（比如停止）
var beat_tween: Tween 
# <<< 新增/修改结束 >>>


func _ready() -> void:
	inner_heart.material = inner_heart.material.duplicate()
	
	# <<< 新增/修改开始 >>>
	# 核心修改：为了让缩放从中心开始，而不是从左上角
	# 我们需要将 pivot_offset (轴心点) 设置为控件的中心
	pivot_offset = size / 2.0
	
	# 游戏开始时，默认是未融化状态，所以直接开始跳动
	start_beating()
	# <<< 新增/修改结束 >>>

# <<< 新增开始 >>>
# --- 创建一个专门负责心跳动画的函数 ---
func start_beating() -> void:
	# 如果当前是融化状态，则不执行心跳动画
	if is_melt:
		return

	# 如果之前有心跳动画在运行，先杀掉它，防止重复创建
	if beat_tween:
		beat_tween.kill()

	# 创建一个新的 Tween 来实现心跳动画
	beat_tween = create_tween()
	
	# 设置动画循环播放
	beat_tween.set_loops()
	
	# 定义动画序列：
	# 1. 在 0.3 秒内，从当前缩放变大到 1.15 倍
	beat_tween.tween_property(self, "scale", Vector2.ONE * 1.15, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# 2. 接着在 0.3 秒内，从 1.15 倍缩放恢复到原始大小 (1.0)
	beat_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# 3. 在下一次心跳前，停顿 0.6 秒，让节奏更像心跳
	beat_tween.tween_interval(0.6)
# <<< 新增结束 >>>


func fade_out() -> void:
	# <<< 新增/修改开始 >>>
	# 在开始融化前，立即停止心跳动画
	if beat_tween:
		beat_tween.kill()
	# 并将大小重置为1，防止它停在放大的状态
	scale = Vector2.ONE
	# <<< 新增/修改结束 >>>

	# 使用 Tween 来创建一个平滑的动画
	var tween = create_tween()
	# 在 tween_duration 秒内，将 "progress" 参数从0动画到1
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
	# 在 tween_duration 秒内，将 "progress" 参数从1动画到0
	tween.tween_method(
		func(value): 
			if inner_heart.material is ShaderMaterial:
				inner_heart.material.set_shader_parameter("progress", value),
		1.0, # 起始值
		0.0, # 结束值
		tween_duration  # 持续时间（秒）
	).set_trans(Tween.TRANS_SINE) # 使用一个缓动函数让动画更自然
	
	# <<< 新增/修改开始 >>>
	# 当恢复动画（fade_in）完成后，我们重新开始心跳
	tween.finished.connect(start_beating)
	# <<< 新增/修改结束 >>>
	
	is_melt = false
