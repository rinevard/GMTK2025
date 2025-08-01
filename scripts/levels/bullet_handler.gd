class_name BulletHandler
extends Node2D

func create_bullet(dir: Vector2, global_pos: Vector2) -> void:
	var bullet = Bullet.new_bullet(dir, global_pos)
	add_child(bullet)
