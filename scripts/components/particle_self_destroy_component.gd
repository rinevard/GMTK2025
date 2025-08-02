## 让粒子开始释放, 释放完成后销毁粒子
extends Node

var particle: Node = null

func _ready() -> void:
	particle = get_parent()
	if particle is GPUParticles2D:
		particle.finished.connect(_on_finished)
		particle.emitting = true
	else:
		push_error("Particle 自毁 component 的父节点不是 particle!")

func _on_finished() -> void:
	print(1)
	particle.call_deferred("queue_free")
