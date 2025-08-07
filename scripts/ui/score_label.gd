extends Label

var dynamic_score: float = 0
var target_score: int = 0
var smoothness: float = 1.0
var speed: float = 0.0
var min_rolling_time: float = 0.15
var middle_rolling_time: float = 0.2
var max_rolling_time: float = 0.26
@onready var score_texture: TextureRect = $"../ScoreTexture"

func _physics_process(delta: float) -> void:
	_set_target_score(PlayerRelatedData.level_score)
	if dynamic_score != target_score:
		dynamic_score += speed * delta
		dynamic_score = clamp(dynamic_score, 0.0, float(target_score))
		text = "%d" % round(dynamic_score)

func _set_target_score(value: int) -> void:
	if target_score == value:
		return
	if abs(target_score - value) < 50.0:
		speed = abs(target_score - value) / min_rolling_time
	elif abs(target_score - value) < 150.0:
		speed = abs(target_score - value) / middle_rolling_time
	else:
		speed = abs(target_score - value) / max_rolling_time
	target_score = value
