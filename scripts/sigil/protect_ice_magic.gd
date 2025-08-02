## 子弹时间的魔法
extends Magic

func apply_on(enemy: Node2D):
	var time_scale_component = enemy.get_node_or_null("TimeScaleComponent")
	if time_scale_component:
		time_scale_component.get_bullet_time()

func remove_on(enemy: Node2D):
	var time_scale_component = enemy.get_node_or_null("TimeScaleComponent")
	if time_scale_component:
		time_scale_component.remove_bullet_time()
