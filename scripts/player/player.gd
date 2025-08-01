class_name Player
extends Node2D

#region 生命
@onready var health_component: HealthComponent = $HealthComponent
var rest_invincible_time: float = 0.0
var max_invincible_time: float = 3.0
#endregion

#region 移动
var max_speed: float = 1200.0
var speed_up_smoothness: float = 30.0
var speed: float = 0.0
#endregion

func _physics_process(delta: float) -> void:
	_update_invincible(delta)
	_update_pos(delta)
	$Label.text = "Health: " + str(health_component.get_health())

func _update_invincible(delta: float) -> void:
	if rest_invincible_time > 0:
		rest_invincible_time -= delta
		# TODO 修改受击显示
		modulate.g = 0
	else:
		modulate.g = 1

func _update_pos(delta: float) -> void:
	# 看起来我们不太需要缓动
	var global_mouse_pos = get_global_mouse_position()
	global_position = global_mouse_pos
	PlayerRelatedData.update_player_data(self)

func _hit(area: Area2D) -> void:
	if rest_invincible_time > 0:
		return
	health_component.hit(1)
	_be_invincible()

func _be_invincible() -> void:
	rest_invincible_time = max_invincible_time

func _on_health_less_than_zero() -> void:
	print("lose!")
