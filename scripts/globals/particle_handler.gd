extends Node2D

# 1. 定义一个枚举(enum)来清晰地表示所有可用的粒子类型
# 当你未来加入新粒子时，只需要在这里添加一个新的名字。
enum ParticleType {
	ATTACKED,
	HEAL,
	DIE # <-- 1. 在这里添加新的粒子类型
}

# 2. 使用一个字典来将枚举映射到预加载的粒子场景
# 这样做的好处是，你只需要在一个地方管理所有的粒子资源。
# 注意：我已经移除了多余的 DIE_PARTICLE 常量，因为它现在由字典统一管理。
const PARTICLE_SCENES: Dictionary = {
	ParticleType.ATTACKED: preload("res://scenes/particles/attacked_particle.tscn"),
	ParticleType.HEAL: preload("res://scenes/particles/heal_particle.tscn"),
	ParticleType.DIE: preload("res://scenes/particles/die_particle.tscn") # <-- 2. 在这里添加新的粒子场景映射
}


# 3. 提供一个公共方法来生成粒子
# 这个函数不需要任何改动，因为它已经被设计为可以处理任何类型。
# 参数:
# - particle_type: 来自我们上面定义的 ParticleType 枚举
# - spawn_position: 粒子在世界空间中的生成位置 (global position)
func spawn_particle(particle_type: ParticleType, spawn_position: Vector2, optional_parent: Node = null):
	# 从字典中查找对应的粒子场景
	var particle_scene = PARTICLE_SCENES.get(particle_type)
	
	# 安全检查：确保这个粒子类型已经在字典中定义了
	if not particle_scene:
		# 使用 ParticleType.keys()[particle_type] 可以获取枚举值的字符串名称，更利于调试
		push_error("粒子类型 '%s' 未在 ParticleManager 中定义！" % ParticleType.keys()[particle_type])
		return
		
	# 实例化粒子场景
	# 我们假设粒子场景的根节点是 CPUParticles2D 或 GPUParticles2D 或任何 Node2D
	var particle_instance = particle_scene.instantiate()
	
	# 将粒子添加到场景树的根节点，这样它就不会意外地随着父节点（如被攻击的敌人）的删除而消失
	if optional_parent:
		optional_parent.add_child(particle_instance)
	else:
		get_tree().root.add_child(particle_instance)
	
	# 设置粒子的全局位置
	particle_instance.global_position = spawn_position
