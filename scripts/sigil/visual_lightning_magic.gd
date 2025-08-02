extends Magic

const LIGHTNING_CENTER = preload("res://scenes/sigils/lightning_center.tscn")
var center: Vector2 = Vector2(-1000, -1000)
var lightning_center: LightningCenter

func _ready() -> void:
	lightning_center = LIGHTNING_CENTER.instantiate()
	add_child(lightning_center)
	var sigil: Node = get_parent().get_parent()
	if sigil is Sigil:
		lightning_center.global_position = sigil.center

func apply_on(enemy: Node2D):
	lightning_center.light_at(enemy.global_position)
	var time_scale_component = enemy.get_node_or_null("TimeScaleComponent")
	if time_scale_component:
		time_scale_component.get_cold()


func remove_on(enemy: Node2D):
	var time_scale_component = enemy.get_node_or_null("TimeScaleComponent")
	if time_scale_component:
		time_scale_component.remove_cold()
