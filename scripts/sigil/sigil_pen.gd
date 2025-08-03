extends Node2D


#region 魔法们
const NORMAL_ATTACK_MAGIC = preload("res://scenes/sigils/normal_attack_magic.tscn")
const PROTECT_ICE_MAGIC = preload("res://scenes/sigils/protect_ice_magic.tscn")
const NORMAL_ICE_MAGIC = preload("res://scenes/sigils/normal_ice_magic.tscn")
const BULLET_DELETE_MAGIC = preload("res://scenes/sigils/bullet_delete_magic.tscn")
const VISUAL_LIGHTNING_MAGIC = preload("res://scenes/sigils/visual_lightning_magic.tscn")
const HEAL_MAGIC = preload("res://scenes/sigils/heal_magic.tscn")
const DUPLICATE_MAGIC = preload("res://scenes/sigils/duplicate_magic.tscn")

const ELEC_LINE = preload("res://resources/elec_line.tres")
const HEAL_LINE = preload("res://resources/heal_line.tres")
const MIRROR_LINE = preload("res://resources/mirror_line.tres")
const SLOW_LINE = preload("res://resources/slow_line.tres")

var shape_to_magic: Dictionary = {
	"cw_pentagon": [PROTECT_ICE_MAGIC], # 顺时针五边形: 子弹时间场
	"ccw_pentagon": [VISUAL_LIGHTNING_MAGIC, NORMAL_ATTACK_MAGIC, BULLET_DELETE_MAGIC], # 逆时针五边形: 电火花场
	"cw_hexagon": [DUPLICATE_MAGIC], # 顺时针六边形: 分身
	"ccw_hexagon": [HEAL_MAGIC], # 逆时针六边形: 生命回复
}
var general_magic = [NORMAL_ATTACK_MAGIC, BULLET_DELETE_MAGIC]
#endregion

## 根据鼠标按下/松开判断是否在画画
var is_drawing: bool = false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_drawing = true
			PlayerRelatedData.is_drawing = true
		else:
			is_drawing = false
			PlayerRelatedData.is_drawing = false
			_end_draw()

## 清空绘制内容
func _end_draw() -> void:
	points = []
	for line in lines:
		line.clear_points()

## 绘制的点
var points: PackedVector2Array = []
## 用于生成魔法阵的点, 应当是一个接近环的东西
var sigil_points: PackedVector2Array = []

## 显示绘制的轨迹
var lines: Array[Line2D] = []
@onready var blue_line: Line2D = $BlueLine

func _ready() -> void:
	lines = [blue_line]

@export var player: Player
var point_distance_threshold: float = 15.0
func _physics_process(delta: float) -> void:
	if is_drawing:
		var new_point = get_global_mouse_position()
		if player:
			new_point = player.broom_end_marker.global_position
		if points.is_empty() or (new_point - points[points.size() - 1]).length() > point_distance_threshold:
			points.append(new_point)
		for line in lines:
			line.points = points
		if _check_self_cross():
			_create_sigil()
			_end_draw()

var intersection_tolerance: float = 40.0 # 自交的允许误差
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

		
		var closest_points = Geometry2D.get_closest_points_between_segments(p_penultimate, p_last, p_i, p_i_plus_1)
		var distance = closest_points[0].distance_to(closest_points[1])
		
		if distance < intersection_tolerance:
			# 2. 构造自交形状的顶点
			var loop_points = PackedVector2Array()
			var intersection_point = closest_points[0].lerp(closest_points[1], 0.5)
			loop_points.append(intersection_point)
			for j in range(i + 1, n - 1):
				loop_points.append(points[j])

			# 3. 计算面积并与阈值比较
			var area = _polygon_area(loop_points)
			if area > area_threshold:
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
	# 2. points
	# 已经被记录过了
	# 3. create
	var magics: Array = []
	var sigil_res: Resource = null
	var duration: float = 0.05
	match sigil_points.size():
		5:
			if _is_sigilpoints_clockwise():
				magics = shape_to_magic["cw_pentagon"] # 子弹时间场
				sigil_res = SLOW_LINE
				duration = 6.4
			else:
				magics = shape_to_magic["ccw_pentagon"] # 电火花场
				sigil_res = ELEC_LINE
				duration = 6.4
		6:
			if _is_sigilpoints_clockwise():
				magics = shape_to_magic["cw_hexagon"] # 分身
				sigil_res = MIRROR_LINE
				duration = 0.5
			else:
				magics = shape_to_magic["ccw_hexagon"] # 生命恢复
				sigil_res = HEAL_LINE
				duration = 0.5
		_:
			magics = general_magic
	var new_sigil: Sigil
	if sigil_res:
		new_sigil = Sigil.new_sigil(sigil_points, magics, duration, sigil_res)
	else:
		new_sigil = Sigil.new_sigil(sigil_points, magics, duration)
	$Sigils.add_child(new_sigil)

func _is_sigilpoints_clockwise() -> bool:
	# 一个多边形至少需要3个点。如果少于3个点，它没有明确的环绕方向。
	var point_count = sigil_points.size()
	if point_count < 3:
		return false

	# 使用鞋带公式计算有符号面积的两倍。
	# 我们只需要知道结果的符号，所以不需要除以2。
	var area_sum: float = 0.0

	for i in range(point_count):
		var current_point = sigil_points[i]
		# 获取下一个点，并使用模运算(%)来处理从最后一个点到第一个点的“环绕”。
		var next_point = sigil_points[(i + 1) % point_count]

		# 累加 (x1*y2 - x2*y1)
		area_sum += (current_point.x * next_point.y) - (next_point.x * current_point.y)

	# 在Godot的2D坐标系中，Y轴是向下的。
	# 因此，如果和为正，则为顺时针；如果为负，则为逆时针。
	# 如果和为0，说明所有点共线，我们将其视为非顺时针。
	return area_sum > 0.0
