## 普通冰霜魔法, 减速敌人
extends Magic

func apply_on(enemy: Node2D):
	var time_scale_component = enemy.get_node_or_null("TimeScaleComponent")
	if time_scale_component:
		time_scale_component.get_cold()

func remove_on(enemy: Node2D):
	var time_scale_component = enemy.get_node_or_null("TimeScaleComponent")
	if time_scale_component:
		time_scale_component.remove_cold()
