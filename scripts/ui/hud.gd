extends Control

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerRelatedData.score_updated.connect(_update_score)

func _update_score() -> void:
	label.text = str(PlayerRelatedData.level_score)
