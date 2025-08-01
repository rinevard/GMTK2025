class_name Sigil
extends Area2D

const SIGIL = preload("res://scenes/sigils/sigil.tscn")
@onready var magic_handler: Node2D = $MagicHandler
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var line_2d: Line2D = $Line2D
var points: PackedVector2Array = []
var magics: Array[Magic] = []
var live_duration: float = 0.3

static func new_sigil(sigil_points: PackedVector2Array, sigil_magics: Array[Magic]) -> Sigil:
	var sigil = SIGIL.instantiate()
	sigil.points = sigil_points
	sigil.magics = sigil_magics
	return sigil

func _ready() -> void:
	var shape = ConvexPolygonShape2D.new()
	shape.points = points
	collision_shape_2d.shape = shape
	line_2d.points = points
	if (points.size() <= 6):
		live_duration = 1.0
	for magic in magics:
		magic_handler.add_child(magic)

func _physics_process(delta: float) -> void:
	live_duration -= delta
	if live_duration < 0:
		_fade_away()

func _fade_away() -> void:
	call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("Enemy"):
		_apply_magics(enemy)

func _apply_magics(enemy: Node2D):
	for magic in magics:
		magic.apply_on(enemy)
