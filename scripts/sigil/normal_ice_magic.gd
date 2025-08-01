extends Magic

@export var damage: int = 1

func apply_on(enemy: Node2D):
	print(enemy.name)
	var health_component = enemy.get_node_or_null("HealthComponent")
	if health_component:
		health_component.hit(damage)
	if enemy.has_method("get_cold"):
		print("cold")
		enemy.is_cold = true
