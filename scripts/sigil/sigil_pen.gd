extends Node2D

#region 魔法们
const NORMAL_ATTACK_MAGIC = preload("res://scenes/sigils/normal_attack_magic.tscn")
#endregion

## 根据鼠标按下/松开判断是否在画画
var is_drawing: bool = false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_drawing = true
		else:
			is_drawing = false
			_end_draw()

## 清空绘制内容
func _end_draw() -> void:
	points = []
	line_2d.clear_points()

## 绘制的点
var points: PackedVector2Array = []
## 用于生成魔法阵的点, 应当是一个接近环的东西
var sigil_points: PackedVector2Array = []

## 显示绘制的轨迹
@onready var line_2d: Line2D = $Line2D
func _physics_process(delta: float) -> void:
	if is_drawing:
		var new_point = get_global_mouse_position()
		points.append(new_point)
		line_2d.points = points
		if _check_self_cross():
			print("点数: ", sigil_points.size())
			_create_sigil()
			_end_draw()

var area_threshold: float = 1000.0
## 1. 自交
## 2. 自交图形面积足够大
## 如果同时满足上面两条, 设置 sigil_points 并返回 true
func _check_self_cross() -> bool:
	var n = points.size()
	# 至少需要4个点才能形成一个非相邻的线段对。
	if n < 4:
		return false

	var p_last = points[n - 1]
	var p_penultimate = points[n - 2]
	for i in range(n - 3):
		# 1. 检查自交
		var p_i = points[i]
		var p_i_plus_1 = points[i + 1]
		var intersection_point = Geometry2D.segment_intersects_segment(p_penultimate, p_last, p_i, p_i_plus_1)
		if intersection_point:
			# 2. 构造自交形状的顶点
			var loop_points = PackedVector2Array()
			loop_points.append(intersection_point)
			for j in range(i + 1, n - 1):
				loop_points.append(points[j])

			# 3. 计算面积并与阈值比较
			var area = _polygon_area(loop_points)
			if area > area_threshold:
				print(area)
				sigil_points = GestureRecognizer.simplify_shape(loop_points)
				return true

	return false

## polygon_points[-1] 不需要与 polygon_points[0] 相同
func _polygon_area(polygon_points: PackedVector2Array) -> float:
	var n = polygon_points.size()
	if n < 3:
		return 0.0 # 不是一个有效的多边形

	var area: float = 0.0
	for i in range(n):
		var j = (i + 1) % n
		area += polygon_points[i].x * polygon_points[j].y
		area -= polygon_points[j].x * polygon_points[i].y
	
	return abs(area) / 2.0

## 自交后被调用来产生魔法阵
func _create_sigil() -> void:
	# 1. magics
	var attack_magic1 = NORMAL_ATTACK_MAGIC.instantiate()
	var attack_magic2 = NORMAL_ATTACK_MAGIC.instantiate()

	# 2. points
	# 已经被记录过了
	
	# 3. create
	var new_sigil = Sigil.new_sigil(sigil_points, [attack_magic1, attack_magic2])
	add_child(new_sigil)
	

func _sample_create_sigil() -> void:
	# 1. magics
	var attack_magic1 = NORMAL_ATTACK_MAGIC.instantiate()
	var attack_magic2 = NORMAL_ATTACK_MAGIC.instantiate()

	# 2. points
	var screen_center: Vector2 = Vector2(1920 / 2.0, 1080 / 2.0)
	var test_points = PackedVector2Array([
		screen_center + Vector2(0, 0),
		screen_center + Vector2(200, 0),
		screen_center + Vector2(0, 300)
	])

	# 3. create
	var new_sigil = Sigil.new_sigil(test_points, [attack_magic1, attack_magic2])
	add_child(new_sigil)
