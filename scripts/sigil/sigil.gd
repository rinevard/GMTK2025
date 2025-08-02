class_name Sigil
extends Area2D

const NORMAL_SIGIL = preload("res://resources/normal_sigil.tres")
const SIGIL = preload("res://scenes/sigils/sigil.tscn")
@onready var magic_handler: Node2D = $MagicHandler
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var polygon_line_2d: Line2D = $PolygonLine2D

var points: PackedVector2Array = []
var magics: Array[Magic] = []
var live_duration: float = 0.3
var sigil_res: SigilResource

static func new_sigil(sigil_points: PackedVector2Array, packed_sigil_magics: Array, duration: float = 0.3, p_sigil_res: SigilResource = NORMAL_SIGIL) -> Sigil:
	var sigil = SIGIL.instantiate()
	sigil.points = sigil_points

	var sigil_magics: Array[Magic] = []
	for packed_magic in packed_sigil_magics:
		var new_magic = packed_magic.instantiate()
		if new_magic is Magic:
			sigil_magics.append(new_magic)

	sigil.magics = sigil_magics
	sigil.live_duration = duration
	sigil.sigil_res = p_sigil_res
	return sigil

func _ready() -> void:
	var shape = ConvexPolygonShape2D.new()
	shape.points = points
	collision_shape_2d.shape = shape
	_play_line_animation()
	for magic in magics:
		magic_handler.add_child(magic)

@onready var animation_container: Node2D = $AnimationContainer
func _play_line_animation() -> void:
	# 为主多边形线段设置基础属性
	polygon_line_2d.points = points
	var polygon_line_texture = sigil_res.polygon_line_texture
	var polygon_line_width = sigil_res.polygon_line_width
	var other_line_texture = sigil_res.other_line_texture
	var other_line_width = sigil_res.other_line_width
	
	polygon_line_2d.texture = polygon_line_texture
	polygon_line_2d.width = polygon_line_width
	
	# 只有五边形和六边形法阵有额外动画
	if points.size() != 5 and points.size() != 6:
		return

	# --- 1. 通用设置：计算中心点 ---
	var center = Vector2.ZERO
	for p in points:
		center += p
	center /= points.size()

	# --- 2. 将动画容器放到中心 ---
	animation_container.position = center
	
	# --- 3. 处理主多边形 ---
	# 将现有的多边形线移动到动画容器中，使其也参与动画
	# 为了正确缩放，我们需要将其顶点坐标转换为相对于中心的坐标
	var relative_points = PackedVector2Array()
	for p in points:
		relative_points.append(p - center)
	
	# 用于存放所有需要创建的新线条
	var new_lines: Array[Line2D] = []

	# --- 4. 分情况处理 ---
	if points.size() == 5:
		# --- 五边形：创建五角星和外接圆 ---
		# 创建五角星 (Pentagram)
		var star_line = _create_line_2d()
		star_line.texture = other_line_texture
		star_line.width = other_line_width
		# 五角星的连接顺序: 0-2, 2-4, 4-1, 1-3, 3-0
		var star_points = PackedVector2Array([
			relative_points[0], relative_points[2], relative_points[4],
			relative_points[1], relative_points[3], relative_points[0]
		])
		star_line.points = star_points
		new_lines.append(star_line)

		# 创建外接椭圆 (Circumscribed Ellipse) - **通过求解线性方程组**
		var ellipse_line = _create_line_2d()
		ellipse_line.texture = other_line_texture
		ellipse_line.width = other_line_width
		# 调用基于线性代数的精确解法
		# 注意：传入的是原始坐标点和中心点
		ellipse_line.points = _calculate_ellipse_by_solving_system(points, center)
		
		# 椭圆比多边形大, 更新碰撞体形状
		var shape = ConvexPolygonShape2D.new()
		var collision_shape_points = PackedVector2Array()
		for p in ellipse_line.points:
			collision_shape_points.append(p + center)
		shape.points = collision_shape_points
		collision_shape_2d.shape = shape

		new_lines.append(ellipse_line)
		
	elif points.size() == 6:
		# --- 六边形：创建六芒星 ---
		# 六芒星由两个三角形组成
		# 第一个三角形 (连接偶数索引的顶点: 0, 2, 4)
		var triangle1_line = _create_line_2d()
		triangle1_line.texture = other_line_texture
		triangle1_line.width = other_line_width
		var triangle1_points = PackedVector2Array([
			relative_points[0], relative_points[2], relative_points[4], relative_points[0]
		])
		triangle1_line.points = triangle1_points
		new_lines.append(triangle1_line)
		
		# 第二个三角形 (连接奇数索引的顶点: 1, 3, 5)
		var triangle2_line = _create_line_2d()
		triangle2_line.texture = other_line_texture
		triangle2_line.width = other_line_width
		var triangle2_points = PackedVector2Array([
			relative_points[1], relative_points[3], relative_points[5], relative_points[1]
		])
		triangle2_line.points = triangle2_points
		new_lines.append(triangle2_line)

	# --- 5. 配置与添加 ---
	for line in new_lines:
		animation_container.add_child(line)

	# --- 6. 创建动画 ---
	# 初始化容器大小为0
	animation_container.scale = Vector2.ZERO
	# 创建一个Tween来实现动画
	var tween = create_tween()
	# 在 live_duration 时间内，将容器的 scale 属性从 Vector2.ZERO 变为 Vector2.ONE
	var anim_duration: float = 0.5
	tween.tween_property(animation_container, "scale", Vector2.ONE, anim_duration) \
		 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

func _physics_process(delta: float) -> void:
	live_duration -= delta
	if live_duration < 0:
		_fade_away()

func _fade_away() -> void:
	call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("Enemy"):
		_apply_magics(enemy)

func _on_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("Enemy"):
		_remove_magics(enemy)

func _apply_magics(enemy: Node2D) -> void:
	for magic in magics:
		if magic.has_method("apply_on"):
			magic.apply_on(enemy)

func _remove_magics(enemy: Node2D) -> void:
	for magic in magics:
		if magic.has_method("remove_on"):
			magic.remove_on(enemy)
# =========================================================================
#                    线性代数精确解法核心函数
# =========================================================================
# 函数 1: 通过求解线性方程组计算外接椭圆的点 (已修正采样逻辑)
func _calculate_ellipse_by_solving_system(p_points: PackedVector2Array, p_center: Vector2) -> PackedVector2Array:
	if p_points.size() != 5:
		return PackedVector2Array()

	# 步骤 1: 构建并求解线性方程组，得到椭圆系数
	var M: Array = []
	var b: Array = []
	for i in range(5):
		var p = p_points[i]
		M.append([p.x * p.y, p.y * p.y, p.x, p.y, 1.0])
		b.append(-p.x * p.x)

	var coeffs = _solve_linear_system(M, b)
	if coeffs.is_empty():
		push_error("Failed to solve linear system for the ellipse. The points might be collinear.")
		return PackedVector2Array()

	var A = 1.0
	var B = coeffs[0]
	var C = coeffs[1]
	var D = coeffs[2]
	var E = coeffs[3]
	var F = coeffs[4]

	# 步骤 2: 计算椭圆的精确几何中心 (cx, cy)
	# 通过求解方程组:
	# 2Ax + By + D = 0
	# Bx + 2Cy + E = 0
	var det = 4 * A * C - B * B
	if abs(det) < 1e-9:
		push_error("Cannot calculate ellipse center: degenerate conic (parabola).")
		return PackedVector2Array()
	
	var ellipse_center_x = (B * E - 2 * C * D) / det
	var ellipse_center_y = (B * D - 2 * A * E) / det
	var ellipse_center = Vector2(ellipse_center_x, ellipse_center_y)

	# 步骤 3: 计算中心化椭圆方程的新常数项 F'
	# A*x'^2 + B*x'y' + C*y'^2 + F' = 0
	# F' = A*cx^2 + B*cx*cy + C*cy^2 + D*cx + E*cy + F
	var F_prime = A * pow(ellipse_center.x, 2) + B * ellipse_center.x * ellipse_center.y + C * pow(ellipse_center.y, 2) + D * ellipse_center.x + E * ellipse_center.y + F

	# 步骤 4: 在中心化的坐标系中进行均匀角度采样
	var ellipse_points = PackedVector2Array()
	var segments = 128 # 使用足够多的点以确保平滑
	
	for i in range(segments + 1):
		var angle = (TAU * i) / segments
		var cos_a = cos(angle)
		var sin_a = sin(angle)

		# 在中心化方程中，解出半径 r'
		# r'^2 * (A*cos_a^2 + B*cos_a*sin_a + C*sin_a^2) + F' = 0
		var r_squared_term = A * cos_a * cos_a + B * cos_a * sin_a + C * sin_a * sin_a
		
		# 确保分母不为零且根号内为正
		if abs(r_squared_term) > 1e-9 and -F_prime / r_squared_term >= 0:
			var r_prime = sqrt(-F_prime / r_squared_term)
			
			# 得到中心化的点 (x', y')
			var centered_point = Vector2.from_angle(angle) * r_prime
			
			# 将点平移回原始全局位置
			var global_point = centered_point + ellipse_center
			
			# 将全局坐标点转换为相对于动画容器中心的坐标
			ellipse_points.append(global_point - p_center)

	return ellipse_points

# 函数 2: 使用高斯消元法求解线性方程组 M*x=b
# M 是一个 Array[Array] (NxN), b 是一个 Array (Nx1)
# 返回解向量 x (Nx1)
func _solve_linear_system(M: Array, b: Array) -> Array:
	var n = b.size()
	var A = [] # 创建增广矩阵的深拷贝
	for i in range(n):
		A.append(M[i].duplicate())
		A[i].append(b[i])

	for i in range(n):
		# 主元选择: 找到第i列绝对值最大的元素所在行
		var max_row = i
		for k in range(i + 1, n):
			if abs(A[k][i]) > abs(A[max_row][i]):
				max_row = k
		var tmp = A[i]
		A[i] = A[max_row]
		A[max_row] = tmp

		# 检查奇异性
		if abs(A[i][i]) < 1e-9:
			return [] # 矩阵是奇异的或接近奇异，无解或无穷多解

		# 将主元行的主元归一化为1
		var pivot = A[i][i]
		for j in range(i, n + 1):
			A[i][j] /= pivot

		# 消去其他行的第i列元素
		for k in range(n):
			if i != k:
				var factor = A[k][i]
				for j in range(i, n + 1):
					A[k][j] -= factor * A[i][j]

	# 提取解
	var x: Array = []
	x.resize(n)
	for i in range(n):
		x[i] = A[i][n]
	
	return x

const CUSTOMIZED_LINE_2D = preload("res://scenes/sigils/customized_line_2d.tscn")
## texture mode -> Tile
## joint mode -> round
## begin cap mode -> round
## end cap mode -> round
func _create_line_2d() -> Line2D:
	var line2d: Line2D = CUSTOMIZED_LINE_2D.instantiate()
	return line2d
