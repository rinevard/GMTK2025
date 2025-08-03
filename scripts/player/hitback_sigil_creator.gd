class_name HitbackSigilCreator

extends Node2D

@export var owner_node2d: Node2D

#region 魔法们
const NORMAL_ATTACK_MAGIC = preload("res://scenes/sigils/normal_attack_magic.tscn")
const PROTECT_ICE_MAGIC = preload("res://scenes/sigils/protect_ice_magic.tscn")
const NORMAL_ICE_MAGIC = preload("res://scenes/sigils/normal_ice_magic.tscn")
const BULLET_DELETE_MAGIC = preload("res://scenes/sigils/bullet_delete_magic.tscn")
const VISUAL_LIGHTNING_MAGIC = preload("res://scenes/sigils/visual_lightning_magic.tscn")
const HEAL_MAGIC = preload("res://scenes/sigils/heal_magic.tscn")
const DUPLICATE_MAGIC = preload("res://scenes/sigils/duplicate_magic.tscn")

const MIRROR_LINE = preload("res://resources/mirror_line.tres")
# 五个平a，一个子弹消除，一个视觉闪电
var hitback_magic = [NORMAL_ATTACK_MAGIC, NORMAL_ATTACK_MAGIC, NORMAL_ATTACK_MAGIC, NORMAL_ATTACK_MAGIC, NORMAL_ATTACK_MAGIC,
					BULLET_DELETE_MAGIC]
var hitback_duration: float = 1.0
#endregion

# 可以在编辑器中调整六边形的大小
@export var sigil_radius: float = 300.0

func create_hitback_sigil() -> void:
	# 1. 计算正六边形的六个顶点
	var points = PackedVector2Array()
	
	# Godot 4 中 TAU 代表 2 * PI，表示一个完整的圆周
	var angle_step = TAU / 6.0
	
	for i in 6:
		var angle = i * angle_step
		# Vector2.from_angle(angle) 创建一个指向该角度的单位向量
		var vertex_position = Vector2.from_angle(angle) * sigil_radius
		points.append(vertex_position)
		
	# 2. 调用 Sigil 类的静态工厂方法来创建魔法阵实例
	# 我们传入计算好的顶点、预设的魔法、持续时间和视觉资源
	var new_sigil: Sigil = Sigil.new_sigil(points, hitback_magic, hitback_duration, MIRROR_LINE)
	new_sigil.global_position = owner_node2d.global_position
	# 3. 将创建好的魔法阵作为子节点添加到当前节点下
	call_deferred("add_child", new_sigil)
