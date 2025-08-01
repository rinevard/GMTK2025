extends Magic

@export var damage: int = 1

func apply_on(enemy: Node2D):
	var health_component = enemy.get_node("HealthComponent")
	if health_component:
		health_component.hit(damage)
	print("attack " + health_component.get_parent().name + "!")
