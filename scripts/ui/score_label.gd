extends Label

var dynamic_score: float = 0
var target_score: int = 0
var smoothness: float = 1.6
var speed: float = 0.0
var max_speed: float = 100.0
@onready var score_texture: TextureRect = $"../ScoreTexture"

func _physics_process(delta: float) -> void:
	target_score = PlayerRelatedData.level_score
	speed = lerp(speed, max_speed, smoothness * delta)
	dynamic_score += speed * delta
	dynamic_score = clamp(dynamic_score, 0.0, float(target_score))
	text = "%d" % round(dynamic_score)
