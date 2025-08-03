extends Node

const MAX_PLAYER_HEALTH: int = 3

# 只应由 player 发出
signal player_hurt()

# 由 player_related_data 即本节点发出
signal player_heal()

# 只应由 player 发出
signal player_lose()

# 由 score handler 订阅
signal score_updated()

# 只应由 dropped_book 发出
signal book_picked(idx: int)

var player_global_pos: Vector2 = Vector2(-1000, -1000)
var duplicate_player_global_positions: Dictionary = {}
var bullet_handler: BulletHandler
var enemy_handler: EnemyHandler
var dropped_handler: DroppedHandler
var player_health_component: HealthComponent
var is_drawing: bool = false # 由 pen 设置
var level_score: int = 0
var level_paused: bool = false

# 
signal level_continuing()

# **【修改/添加部分 1/5：添加屏幕震动所需变量】**
var _shake_timer: Timer
var _shake_amplitude: Vector2 = Vector2.ZERO
# **【修改/添加部分结束】**


# **【修改/添加部分 2/5：添加 _ready 函数来初始化 Timer】**
func _ready() -> void:
	# 创建一个定时器来控制震动时长
	_shake_timer = Timer.new()
	add_child(_shake_timer)
	# 连接定时器的 timeout 信号，以便在震动结束后重置相机位置
	_shake_timer.timeout.connect(_on_shake_timer_timeout)
# **【修改/添加部分结束】**


# **【修改/添加部分 3/5：添加 _process 函数来处理每一帧的震动】**
func _physics_process(delta: float) -> void:
	# 如果定时器停止了，说明没有震动，直接返回
	if _shake_timer.is_stopped():
		return
	
	# 计算衰减系数。震动快结束时，强度接近0；刚开始时，强度接近1。
	var fade: float = 1.0 - (_shake_timer.wait_time - _shake_timer.time_left) / _shake_timer.wait_time
	# 使用 ease-out 曲线让衰减更自然（可选，但效果更好）
	fade = ease(fade, 2.0)
	
	# 根据当前振幅和衰减计算这一帧的震动强度
	var current_strength: Vector2 = _shake_amplitude * fade
	
	# 生成一个随机方向的单位向量，乘以强度，作为相机偏移
	# randf_range(-1.0, 1.0) 会生成一个在 -1.0 和 1.0 之间的随机浮点数
	var random_offset: Vector2 = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	)
	
	if level_camera:
		level_camera.offset = random_offset.normalized() * current_strength
# **【修改/添加部分结束】**


func init_player_data(player: Player) -> void:
	player_global_pos = player.global_position
	player_health_component = player.health_component

## 只应由 player 调用
func update_player_data(player: Player) -> void:
	player_global_pos = player.global_position

## 只应由复制品调用
func update_duplicate_player_pos(duplicate_player_id: int, global_pos: Vector2):
	duplicate_player_global_positions[duplicate_player_id] = global_pos

## 只应由复制品调用
func remove_duplicate_player(duplicate_player_id: int):
	duplicate_player_global_positions.erase(duplicate_player_id)

func heal_player(value: int) -> void:
	player_health_component.heal(value)
	player_heal.emit()

var level_camera: Camera2D
## 只应由 level 调用
func update_level(level: Level) -> void:
	bullet_handler = level.bullet_handler
	enemy_handler = level.enemy_handler
	dropped_handler = level.dropped_handler
	level_camera = level.camera_2d
	level_score = 0
	score_updated.emit()


# **【修改/添加部分 4/5：实现 screen_shake 函数】**
func screen_shake(strength: float, collision_global_pos: Vector2, duration: float) -> void:
	# 如果没有相机引用，或者振幅为0，则不执行
	var amplitude = (level_camera.global_position - collision_global_pos).normalized() * strength
	if not level_camera or amplitude == Vector2.ZERO:
		return
	
	# 保存震动参数
	_shake_amplitude = amplitude
	
	# 设置并启动定时器，这将覆盖上一次的震动（如果存在）
	_shake_timer.wait_time = duration
	_shake_timer.start()
# **【修改/添加部分结束】**


# **【修改/添加部分 5/5：添加 Timer 超时处理函数】**
func _on_shake_timer_timeout() -> void:
	# 震动结束，将相机偏移量重置为零，确保它回到原始位置
	if level_camera:
		level_camera.offset = Vector2.ZERO
	# 重置振幅变量
	_shake_amplitude = Vector2.ZERO
# **【修改/添加部分结束】**


func get_bullet_handler() -> BulletHandler:
	return bullet_handler

func get_enemy_handler() -> EnemyHandler:
	return enemy_handler

func get_dropped_handler() -> DroppedHandler:
	return dropped_handler

## 这可能会返回分身的位置
func get_player_global_pos() -> Vector2:
	if duplicate_player_global_positions.size() > 0:
		return duplicate_player_global_positions.values().back()
	return player_global_pos

func level_get_score(score: int) -> void:
	if score == 0:
		return
	level_score += score
	score_updated.emit()
