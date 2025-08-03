extends Control

@onready var heart_container: HBoxContainer = $HeartContainer
var hud_hearts: Array[HudHeart] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerRelatedData.player_heal.connect(get_heart)
	PlayerRelatedData.player_hurt.connect(lose_heart)
	PlayerRelatedData.score_updated.connect(_update_score)
	for heart in heart_container.get_children():
		if heart is HudHeart:
			hud_hearts.append(heart)

func lose_heart() -> void:
	for i in range(hud_hearts.size() - 1, -1, -1):
		if not hud_hearts[i].is_melt:
			hud_hearts[i].fade_out()
			break

func get_heart() -> void:
	for heart: HudHeart in hud_hearts:
		if heart.is_melt:
			heart.fade_in()
			break

func _update_score() -> void:
	pass
