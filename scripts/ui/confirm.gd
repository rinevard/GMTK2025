extends TextureButton

# --- 可在检查器中调整的参数 ---
# 悬停时放大到的倍数
@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
# 按下时缩小到的倍数
@export var pressed_scale: Vector2 = Vector2(0.9, 0.9)
# 悬停时向上移动的像素
@export var hover_pop_up_amount: float = -8.0 # 负值表示向上移动
# 按下时向下移动的像素
@export var pressed_drop_down_amount: float = 4.0 # 正值表示向下移动
# 动画的持续时间（秒）
@export var animation_duration: float = 0.1

# 用于存储按钮的初始状态
var initial_position: Vector2
var initial_scale: Vector2

# 用于管理动画，防止动画冲突
var current_tween: Tween


func _ready() -> void:
	# 在游戏开始时，保存按钮的初始位置和缩放
	initial_position = self.position
	initial_scale = self.scale

	# ---- 连接信号 ----
	# 你可以在检查器(Inspector)的Node->Signals面板连接这些信号，或者像这样用代码连接
	# 如果你已经在检查器里连接了，就不需要下面这四行了
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.button_down.connect(_on_button_down)
	self.button_up.connect(_on_button_up)

	# 关键步骤：为了让缩放和位移动画看起来正确，需要设置轴心点(Pivot)在中心
	# 否则按钮会向右下角缩放
	self.pivot_offset = self.size / 2


# 核心动画函数
func animate(target_scale: Vector2, target_position: Vector2) -> void:
	# 如果当前有动画正在播放，先停止它，以播放新的动画
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	# 创建一个新的Tween实例
	current_tween = create_tween()
	# 设置动画过渡类型，让效果更平滑自然
	current_tween.set_trans(Tween.TRANS_SINE) # 使用正弦曲线过渡
	current_tween.set_ease(Tween.EASE_OUT)    # 缓出效果
	
	# 同时执行多个属性的动画
	current_tween.set_parallel(true)
	
	# 添加缩放动画
	current_tween.tween_property(self, "scale", target_scale, animation_duration)
	# 添加位置动画
	current_tween.tween_property(self, "position", target_position, animation_duration)


# 鼠标进入按钮区域时调用
func _on_mouse_entered() -> void:
	# 只有当按钮没有被按住时，才触发悬停效果
	if not self.button_pressed:
		var target_pos = initial_position + Vector2(0, hover_pop_up_amount)
		animate(hover_scale, target_pos)


# 鼠标离开按钮区域时调用
func _on_mouse_exited() -> void:
	# 无论如何都恢复到初始状态
	animate(initial_scale, initial_position)

signal magic_book_confirm()
# 鼠标按下按钮时调用
func _on_button_down() -> void:
	var target_pos = initial_position + Vector2(0, pressed_drop_down_amount)
	animate(pressed_scale, target_pos)

# 鼠标松开时调用（无论是在按钮上还是在按钮外松开）
func _on_button_up() -> void:
	# 检查松开时鼠标是否还在按钮上
	if self.is_hovered():
		# 如果在，恢复到悬停状态
		_on_mouse_entered()
	else:
		# 如果不在，恢复到初始状态
		_on_mouse_exited()
