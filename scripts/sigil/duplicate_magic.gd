extends Magic

var center: Vector2 = Vector2.ZERO
func _ready() -> void:
	var sigil: Node = get_parent().get_parent()
	if sigil is Sigil:
		center = sigil.center
	var dup_player = DuplicatePlayer.new_duplicate_player(center)
	PlayerRelatedData.get_dropped_handler().call_deferred("add_child", dup_player)

func apply_on(enemy: Node2D):
	pass
