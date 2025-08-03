## 1. 捡到过这本书之前，弹窗然后出法阵
## 2. 遇到之后，直接出法阵

class_name DroppedBook
extends Area2D

signal ui_need_show_magic_book()
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

#region --- 开始：为实现漂浮效果新增的变量 ---
# @export 关键字让这些变量可以在 Godot 编辑器的“检查器”面板中方便地进行调整
@export var float_amplitude: float = 16.0 # 漂浮的振幅（上下移动的距离）
@export var float_speed: float = 1.5 # 漂浮的速度（数值越大，上下移动越快）

var time_passed: float = 0.0 # 用于累计时间，驱动正弦函数
var initial_position_y: float # 用于存储书本的初始Y坐标
#endregion --- 结束：为实现漂浮效果新增的变量 ---


# 顺五冰, 逆五电, 顺六镜, 逆六奶
var sigil_shapes: Array[String] = [
	"cw_pentagon",
	"ccw_pentagon",
	"cw_hexagon",
	"ccw_hexagon",
]
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
var shape_to_sfx: Dictionary = {
	"cw_pentagon": SfxPlayer.SFXs.ICE, # 顺时针五边形: 子弹时间场
	"ccw_pentagon": SfxPlayer.SFXs.LIGHTNING, # 逆时针五边形: 电火花场
	"cw_hexagon": SfxPlayer.SFXs.DRAWING_FAIL, # 顺时针六边形: 分身
	"ccw_hexagon": SfxPlayer.SFXs.HEAL, # 逆时针六边形: 生命回复
}
#endregion
const BOOK_1 = preload("res://assets/art/final_arts/book/book1.png")
const BOOK_2 = preload("res://assets/art/final_arts/book/book2.png")
const BOOK_3 = preload("res://assets/art/final_arts/book/book3.png")
const BOOK_4 = preload("res://assets/art/final_arts/book/book4.png")
@onready var sprite_2d: Sprite2D = $Sprite2D

var shape_to_texture: Dictionary = {
	"cw_pentagon": BOOK_1, # 顺五 (冰) -> 减速线
	"ccw_pentagon": BOOK_2, # 逆五 (电) -> 闪电线
	"cw_hexagon": BOOK_3, # 顺六 (镜) -> 镜像线
	"ccw_hexagon": BOOK_4, # 逆六 (奶) -> 治疗线
}

# --- 开始: 修改 ---
# 根据注释中的HSV值，我们使用Color.from_hsv来创建颜色。
# 注意：Godot的from_hsv需要0-1范围的值，所以我们对原始值进行转换。
var shape_to_color: Dictionary = {
	# 顺五 (冰) -> HSV(205, 95, 100)
	"cw_pentagon": Color.from_hsv(205.0 / 360.0, 95.0 / 100.0, 100.0 / 100.0),
	# 逆五 (电) -> HSV(42, 86, 100)
	"ccw_pentagon": Color.from_hsv(42.0 / 360.0, 86.0 / 100.0, 100.0 / 100.0),
	# 顺六 (镜) -> HSV(346, 71, 100)
	"cw_hexagon": Color.from_hsv(346.0 / 360.0, 71.0 / 100.0, 100.0 / 100.0),
	# 逆六 (奶) -> HSV(178, 100, 72)
	"ccw_hexagon": Color.from_hsv(178.0 / 360.0, 100.0 / 100.0, 72.0 / 100.0)
}
# --- 结束: 修改 ---

var shape_to_line: Dictionary = {
	"cw_pentagon": SLOW_LINE, # 顺五 (冰) -> 减速线
	"ccw_pentagon": ELEC_LINE, # 逆五 (电) -> 闪电线
	"cw_hexagon": MIRROR_LINE, # 顺六 (镜) -> 镜像线
	"ccw_hexagon": HEAL_LINE, # 逆六 (奶) -> 治疗线
}

var sigil_radius: float = 300.0
var rand_idx: int = randi_range(0, sigil_shapes.size() - 1)

func _ready() -> void:
	# 记录书本的初始Y坐标，作为漂浮的中心点
	initial_position_y = self.position.y

	var current_shape: String = sigil_shapes[rand_idx]
	sprite_2d.texture = shape_to_texture[current_shape]

	# --- 开始: 新增修改 ---
	# 根据形状获取对应的颜色
	var shader_color: Color = shape_to_color[current_shape]
	# 设置shader的 "color" uniform参数
	# 前提：你的Sprite2D节点在检查器中已经附加了一个ShaderMaterial
	if sprite_2d.material is ShaderMaterial:
		sprite_2d.material = sprite_2d.material.duplicate()
		sprite_2d.material.set_shader_parameter("color", shader_color)
	else:
		# 如果没有ShaderMaterial，打印一个警告，方便调试
		push_warning("DroppedBook's Sprite2D does not have a ShaderMaterial assigned.")
	# --- 结束: 新增修改 ---


#region --- 开始：为实现漂浮效果新增的函数 ---
# _process 函数每一帧都会被调用
func _process(delta: float) -> void:
	# 累加每帧的间隔时间
	time_passed += delta
	
	# 使用 sin() 函数计算Y坐标的偏移量。
	# sin() 的值会在 -1 和 1 之间平滑地变化，乘以振幅 float_amplitude 即可得到最终的偏移。
	# time_passed * float_speed 控制了 sin() 函数变化的快慢，从而控制漂浮速度。
	var y_offset = sin(time_passed * float_speed) * float_amplitude
	
	# 将计算出的偏移量应用到书本的Y坐标上，实现漂浮
	self.position.y = initial_position_y + y_offset
#endregion --- 结束：为实现漂浮效果新增的函数 ---


func _on_area_entered(area: Area2D) -> void:
	if not SaveManager.books_seen_arr[rand_idx]:
		_ui_show_magic_book()
		SfxPlayer.play_sfx(SfxPlayer.SFXs.UI_INTRO)
		SaveManager.books_seen_arr[rand_idx] = true
		SaveManager.save_game()
		await PlayerRelatedData.level_continuing
	_generate_random_sigil(rand_idx)
	_remove_self()

func _generate_random_sigil(idx: int) -> void:
	# 1. 根据索引获取法阵的名称和对应属性
	var shape_name: String = sigil_shapes[idx]
	
	var num_vertices: int
	var duration: float
	var line_resource: Resource = shape_to_line[shape_name]
	var magic_array: Array = shape_to_magic[shape_name]
	var magic_sfx: SfxPlayer.SFXs = shape_to_sfx[shape_name]
	SfxPlayer.play_sfx(magic_sfx)
	# 根据法阵名称确定顶点数和持续时间
	if shape_name.contains("pentagon"):
		num_vertices = 5
		duration = 6.4 # 五边形持续时间
	else: # 法阵是六边形
		num_vertices = 6
		duration = 0.5 # 六边形持续时间
		PlayerRelatedData.screen_shake(8.0, global_position, 0.3)
		
	# 2. 计算法阵的顶点
	var points = PackedVector2Array()
	
	# Godot 4 中 TAU 代表 2 * PI，表示一个完整的圆周
	var angle_step = TAU / num_vertices
	# 如果是顺时针 ("cw")，则反转角度步长
	if shape_name.begins_with("cw"):
		angle_step = - angle_step
	
	for i in range(num_vertices):
		var angle = i * angle_step
		# Vector2.from_angle(angle) 创建一个指向该角度的单位向量
		var vertex_position = Vector2.from_angle(angle) * sigil_radius
		# 以掉落书本的全局位置为中心生成法阵
		points.append(vertex_position + global_position)

	# 3. 调用 Sigil 类的静态工厂方法来创建魔法阵实例
	# 假设 Sigil 是一个已在别处定义的类名 (class_name Sigil)，拥有静态方法 new_sigil
	var new_sigil = Sigil.new_sigil(points, magic_array, duration, line_resource)
	
	# 4. 将创建好的魔法阵作为子节点添加到当前节点下
	# 使用 call_deferred 以避免在物理帧期间修改场景树
	$Node.call_deferred("add_child", new_sigil)

func _ui_show_magic_book() -> void:
	PlayerRelatedData.book_picked.emit(rand_idx)

func _remove_self() -> void:
	#region --- 开始：为实现漂浮效果修改的代码 ---
	# 在移除书本前，禁用 _process 函数，停止漂浮计算，这是一种优化。
	set_process(false)
	#endregion --- 结束：为实现漂浮效果修改的代码 ---
	$Sprite2D.visible = false
	collision_shape_2d.call_deferred("set_disabled", true)
	get_tree().create_timer(20.0).timeout.connect(_call_deferred_free)

func _call_deferred_free() -> void:
	call_deferred("queue_free")
