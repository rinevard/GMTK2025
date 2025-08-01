extends Node

# --- 配置常量 ---
# Ramer-Douglas-Peucker 算法的 epsilon 值。
# 这个值代表点可以偏离简化线的最大距离，决定了简化的程度。
# 值越大，简化越强，可能会丢失细节；值越小，保留的细节越多，可能对噪点敏感。
# 根据游戏画布大小来调整。
# 这个值是否可以像下面的 CLOSE_LOOP_THRESHOLD_RATIO 一样，用比例而非固定值？
const RDP_EPSILON = 50.0

# 定义一个“角”的角度阈值（单位：度）。
# 一个平滑的曲线角度接近180度。我们认为小于这个值的都是角。
const CORNER_ANGLE_THRESHOLD_DEGREES = 150.0

# 闭合路径检查的阈值。
# 如果路径的起点和终点的距离小于图形包围盒对角线长度的这个比例，
# 我们就认为它是闭合的。使用比例比使用固定像素值更具适应性。
const CLOSE_LOOP_THRESHOLD_RATIO = 0.2

# ------------------------------------------------------------------ #
# Public API
# ------------------------------------------------------------------ #

## points[-1] 不需要与 points[0] 相同
func simplify_polygon(points: PackedVector2Array) -> PackedVector2Array:
	var rdp_simplified_points = _simplify_path_rdp(points)
	var corner_simplified_points = _simplify_path_corner(rdp_simplified_points)
	return corner_simplified_points

## points[-1] 不需要与 points[0] 相同
func _simplify_path_corner(points: PackedVector2Array, angle_threshold_deg: float = CORNER_ANGLE_THRESHOLD_DEGREES) -> PackedVector2Array:
	# 如果点少于3个，无法形成角，直接返回原路径
	if points.size() < 3:
		return points
	
	var angle_threshold_rad: float = deg_to_rad(angle_threshold_deg)

	var simplified_points: PackedVector2Array = []
	var path_size: int = points.size()
	
	# 我们将路径视为循环的，以便正确处理起点和终点
	for i in range(path_size):
		var p_prev: Vector2 = points[(i - 1 + path_size) % path_size]
		var p_curr: Vector2 = points[i]
		var p_next: Vector2 = points[(i + 1) % path_size]
		
		# 从当前点指向前后邻居的向量
		var v1: Vector2 = p_prev - p_curr
		var v2: Vector2 = p_next - p_curr
		
		# 如果存在重复点，跳过
		if is_zero_approx(v1.length_squared()) or is_zero_approx(v2.length_squared()):
			continue

		v1 = v1.normalized()
		v2 = v2.normalized()
		
		var dot_product: float = clamp(v1.dot(v2), -1.0, 1.0)
		var angle: float = acos(dot_product)
		
		# 如果角度小于阈值，说明这是一个明显拐角，保留
		if angle < angle_threshold_rad:
			simplified_points.append(p_curr)
		# 否则丢弃该点，从而拉直该线段
			
	return simplified_points

# ------------------------------------------------------------------ #
# Algorithm Implementation
# ------------------------------------------------------------------ #

## points[-1] 不需要与 points[0] 相同
## 使用 Ramer-Douglas-Peucker 算法简化路径
func _simplify_path_rdp(points: PackedVector2Array, epsilon: float = RDP_EPSILON) -> PackedVector2Array:
	if points.size() < 3:
		return points

	var first_point = points[0]
	var last_point = points[points.size() - 1]
	
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
		
		# 移除重复点并合并结果
		rec_results1.remove_at(rec_results1.size() - 1)
		return rec_results1 + rec_results2
	else:
		var result = PackedVector2Array()
		result.append(first_point)
		result.append(last_point)
		return result
