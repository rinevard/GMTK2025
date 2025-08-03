## 1. 捡到过这本书之前，弹窗然后出法阵
## 2. 遇到之后，直接出法阵

class_name DroppedBook
extends Area2D

signal ui_need_show_magic_book()
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# 顺五冰, 逆五电, 逆六奶, 顺六镜
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
#endregion

var shape_to_line: Dictionary = {
	"cw_pentagon": SLOW_LINE, # 顺五 (冰) -> 减速线
	"ccw_pentagon": ELEC_LINE, # 逆五 (电) -> 闪电线
	"cw_hexagon": MIRROR_LINE, # 顺六 (镜) -> 镜像线
	"ccw_hexagon": HEAL_LINE, # 逆六 (奶) -> 治疗线
}

var sigil_radius: float = 300.0
var rand_idx: int = randi_range(0, sigil_shapes.size() - 1)

func _on_area_entered(area: Area2D) -> void:
	if not SaveManager.books_seen_arr[rand_idx]:
		_ui_show_magic_book()
		SaveManager.books_seen_arr[rand_idx] = true
		SaveManager.save_game()
	await get_tree().create_timer(0.1).timeout
	_generate_random_sigil(rand_idx)
	_remove_self()

func _generate_random_sigil(idx: int) -> void:
	# 1. 根据索引获取法阵的名称和对应属性
	var shape_name: String = sigil_shapes[idx]
	
	var num_vertices: int
	var duration: float
	var line_resource: Resource = shape_to_line[shape_name]
	var magic_array: Array = shape_to_magic[shape_name]
	
	# 根据法阵名称确定顶点数和持续时间
	if shape_name.contains("pentagon"):
		num_vertices = 5
		duration = 6.4 # 五边形持续时间
	else: # 法阵是六边形
		num_vertices = 6
		duration = 0.5 # 六边形持续时间
		
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
	$Sprite2D.visible = false
	collision_shape_2d.call_deferred("set_disabled", true)
	get_tree().create_timer(20.0).timeout.connect(_call_deferred_free)

func _call_deferred_free() -> void:
	call_deferred("queue_free")
