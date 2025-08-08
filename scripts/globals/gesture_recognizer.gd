extends Node

# --- 配置常量 ---
# Ramer-Douglas-Peucker 算法的 epsilon 值。
const RDP_EPSILON = 50.0
# 定义一个“角”的角度阈值（单位：度）。
const CORNER_ANGLE_THRESHOLD_DEGREES = 160.0

# 多边形拟合误差阈值。
const POLYGON_FIT_ERROR_THRESHOLD = 12.0

# --- 新增常量 for 滑动平均算法 ---
# 滑动平均的迭代次数。次数越多，曲线越平滑，但收缩也越明显。
const MOVING_AVERAGE_ITERATIONS = 8
# 平滑因子 (0.0 到 1.0)。
# 0.0 = 没有平滑。
# 1.0 = 将点完全移动到其邻居的平均位置。
# 0.5 是一个很好的起点，它在保留原始形状和平滑之间取得了平衡。
const SMOOTHING_FACTOR = 0.8

# ------------------------------------------------------------------ #
# Public API - 主要入口函数
# ------------------------------------------------------------------ #

##
# 简化用户绘制的路径。
# 该函数会首先尝试将路径简化为多边形。
# 如果多边形与原始路径的拟合度不高（误差较大），
# 函数会转而使用滑动平均算法来平滑原始路径，消除抖动。
#
# @param original_points: 用户绘制的原始、未简化的点集。
#                         此路径被假定为闭合环路。
# @return: 一个 PackedVector2Array，表示简化的多边形或平滑后的曲线。
##
func simplify_shape(original_points: PackedVector2Array) -> PackedVector2Array:
	# 确保有足够的点来进行有意义的分析
	if original_points.size() < 8:
		return original_points

	var is_clockwise = _is_points_clockwise(original_points)
	# 找凸包
	var convex_points: PackedVector2Array = Geometry2D.convex_hull(original_points)
	# convex_hull 函数描述里的 "counterclockwise" 是相对其坐标系而言的
	# 我们用的 counterclockwise 是相对玩家所见而言的
	# 因此要 reverse 一下, 才能让 convex_points 是相对于我们的 counterclockwise
	convex_points.reverse()
	# 去重
	convex_points.remove_at(convex_points.size() - 1)
	if is_clockwise:
		convex_points.reverse()

	# 简化路径
	var rdp_simplified_points = _simplify_path_rdp(convex_points, RDP_EPSILON)
	var simplified_polygon = _simplify_path_corner(rdp_simplified_points)
	
	# 只返回五边形和六边形
	if simplified_polygon.size() != 5 and simplified_polygon.size() != 6:
		return _smooth_path_moving_average_closed(convex_points, MOVING_AVERAGE_ITERATIONS, SMOOTHING_FACTOR)

	# 避免画的五边形被误判为六边形
	if simplified_polygon.size() == 6:
		simplified_polygon = _simplify_hexagon_by_length(simplified_polygon)
	# 评估多边形拟合的质量
	var fit_error = _calculate_polygon_fit_error(convex_points, simplified_polygon)
	
	# 如果误差低，判定为多边形，结束。
	if fit_error <= POLYGON_FIT_ERROR_THRESHOLD:
		return simplified_polygon
	else:
		# 如果没判定为多边形，使用滑动平均算法来平滑
		return _smooth_path_moving_average_closed(convex_points, MOVING_AVERAGE_ITERATIONS, SMOOTHING_FACTOR)

func _is_points_clockwise(points: PackedVector2Array) -> bool:
	var point_count = points.size()
	if point_count < 3:
		return false

	# 使用鞋带公式计算有符号面积
	var area_sum: float = 0.0

	for i in range(point_count):
		var current_point = points[i]
		var next_point = points[(i + 1) % point_count]
		area_sum += (current_point.x * next_point.y) - (next_point.x * current_point.y)

	return area_sum > 0.0

const LENGTH_THRESHOLD: float = 50.0
func _simplify_hexagon_by_length(points: PackedVector2Array, len_threshold: float = LENGTH_THRESHOLD) -> PackedVector2Array:
	var points_size: int = points.size()
	var simplified_polygon: PackedVector2Array = []
	for i in range(points_size):
		var p_curr = points[i]
		var p_next = points[(i + 1) % points_size]
		if (p_next - p_curr).length() >= len_threshold:
			simplified_polygon.append(p_curr)
	return simplified_polygon

# ------------------------------------------------------------------ #
# 新增的滑动平均算法 (假定输入为闭合环路)
# ------------------------------------------------------------------ #

##
# 使用滑动平均算法平滑一个闭合的路径。
#
# @param points: 需要平滑的原始点集 (必须是闭合环路)。
# @param iterations: 迭代次数。
# @param smoothing_factor: 平滑强度 (0.0 - 1.0)。
# @return: 一个表示平滑曲线的 PackedVector2Array。
##
func _smooth_path_moving_average_closed(points: PackedVector2Array, iterations: int, smoothing_factor: float) -> PackedVector2Array:
	if points.size() < 3 or iterations <= 0 or smoothing_factor <= 0.0:
		return points

	var smoothed_points = points
	for i in range(iterations):
		smoothed_points = _moving_average_iteration_closed(smoothed_points, smoothing_factor)
	
	return smoothed_points

##
# 执行单次滑动平均迭代 (闭合环路版本)。
# 每个点的新位置是其原始位置和其前后邻居平均位置之间的线性插值。
#
# @param path: 当前迭代的路径点集 (必须是闭合环路)。
# @param smoothing_factor: 平滑强度。
# @return: 单次平滑后的新路径点集。
##
func _moving_average_iteration_closed(path: PackedVector2Array, smoothing_factor: float) -> PackedVector2Array:
	var new_path = PackedVector2Array()
	var n = path.size()

	if n < 3:
		return path
		
	for i in range(n):
		# 使用 modulo (%) 操作符来优雅地处理环路
		var p_prev = path[(i - 1 + n) % n]
		var p_curr = path[i]
		var p_next = path[(i + 1) % n]
		
		# 计算前后两个邻居的中心点
		var neighbor_avg = (p_prev + p_next) / 2.0
		
		# 将当前点向邻居的中心点移动一定比例 (smoothing_factor)
		# lerp(from, to, weight)
		var new_point = p_curr.lerp(neighbor_avg, smoothing_factor)
		
		new_path.append(new_point)
		
	return new_path


# ------------------------------------------------------------------ #
# 保持不变的辅助函数
# ------------------------------------------------------------------ #

## 计算原始点集到简化后多边形的平均距离（拟合误差）
func _calculate_polygon_fit_error(original_points: PackedVector2Array, polygon_points: PackedVector2Array) -> float:
	if original_points.is_empty() or polygon_points.size() < 2:
		return 0.0

	var total_distance: float = 0.0
	
	for p_orig in original_points:
		var min_dist_sq: float = INF
		
		for i in range(polygon_points.size()):
			var p1 = polygon_points[i]
			var p2 = polygon_points[(i + 1) % polygon_points.size()]
			
			var closest_point_on_segment = Geometry2D.get_closest_point_to_segment(p_orig, p1, p2)
			min_dist_sq = min(min_dist_sq, p_orig.distance_squared_to(closest_point_on_segment))
		
		total_distance += sqrt(min_dist_sq)

	return total_distance / original_points.size()

func _simplify_path_corner(points: PackedVector2Array, angle_threshold_deg: float = CORNER_ANGLE_THRESHOLD_DEGREES) -> PackedVector2Array:
	if points.size() < 3: return points
	var angle_threshold_rad: float = deg_to_rad(angle_threshold_deg)
	var simplified_points: PackedVector2Array = []
	var path_size: int = points.size()
	for i in range(path_size):
		var p_prev: Vector2 = points[(i - 1 + path_size) % path_size]
		var p_curr: Vector2 = points[i]
		var p_next: Vector2 = points[(i + 1) % path_size]
		var v1: Vector2 = p_prev - p_curr
		var v2: Vector2 = p_next - p_curr
		if is_zero_approx(v1.length_squared()) or is_zero_approx(v2.length_squared()): continue
		v1 = v1.normalized()
		v2 = v2.normalized()
		var dot_product: float = clamp(v1.dot(v2), -1.0, 1.0)
		var angle: float = acos(dot_product)
		if angle < angle_threshold_rad:
			simplified_points.append(p_curr)
	return simplified_points

func _simplify_path_rdp(points: PackedVector2Array, epsilon: float = RDP_EPSILON) -> PackedVector2Array:
	if points.size() < 3: return points
	var first_point = points[0]
	var last_point = points[points.size() - 1]
	# 检查是否闭合路径的RDP特殊处理
	if first_point.is_equal_approx(last_point):
		# 对于闭合路径，找到离基线（首尾点）最远的点
		var max_dist = 0.0
		var index = -1
		for i in range(1, points.size() - 1):
			var dist = Geometry2D.get_closest_point_to_segment(points[i], first_point, last_point).distance_to(points[i])
			if dist > max_dist:
				max_dist = dist
				index = i
		if max_dist > epsilon and index != -1:
			# 以最远点为新的起点/终点，重新排列点集并递归
			var reordered_points = PackedVector2Array()
			for i in range(points.size() - 1):
				reordered_points.append(points[(index + i) % (points.size() - 1)])
			reordered_points.append(reordered_points[0]) # 闭合路径
			
			var result = _simplify_path_rdp(reordered_points, epsilon)
			# 移除最后一个重复点
			if !result.is_empty(): result.remove_at(result.size() - 1)
			return result
		else: # 简化到只剩两个点（一条线），对于闭合路径这意味着没有角
			return PackedVector2Array([first_point])
	else: # 原有的开放路径逻辑
		var max_dist = 0.0
		var index = 0
		for i in range(1, points.size() - 1):
			var dist = Geometry2D.get_closest_point_to_segment(points[i], first_point, last_point).distance_to(points[i])
			if dist > max_dist:
				max_dist = dist
				index = i
		if max_dist > epsilon:
			var rec_results1 = _simplify_path_rdp(points.slice(0, index + 1), epsilon)
			var rec_results2 = _simplify_path_rdp(points.slice(index), epsilon)
			rec_results1.remove_at(rec_results1.size() - 1)
			return rec_results1 + rec_results2
		else:
			var result = PackedVector2Array()
			result.append(first_point)
			result.append(last_point)
			return result
