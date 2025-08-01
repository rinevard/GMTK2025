class_name BulletHandler
extends Node2D

func create_bullet(dir: Vector2, global_pos: Vector2) -> void:
	var bullet = Bullet.new_bullet(dir, global_pos)
	add_child(bullet)

func clear_bullets() -> void:
	var bullets: Array = get_children()
	for bullet in bullets:
		if bullet.has_method("die"):
			bullet.die()
