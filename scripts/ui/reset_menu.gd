class_name ResetMenu
extends Control

signal reset_level()
signal back_to_start()

func _on_reset_button_pressed() -> void:
	reset_level.emit()

func _on_back_start_menu_button_pressed() -> void:
	back_to_start.emit()

func _ready() -> void:
	jump_out()

@onready var score_label: Label = $HBoxContainer/VBoxContainer2/ScoreLabel
@onready var best_label: Label = $HBoxContainer/VBoxContainer2/BestLabel

func _label_roll_number() -> void:
	# 1. 获取本次得分和旧的最高分
	var level_score: int = PlayerRelatedData.level_score
	var old_best_score: int = SaveManager.high_score

	# 检查是否创造了新纪录
	var is_new_best: bool = level_score > old_best_score
	
	# 2. 如果是新纪录，立即更新数据模型中的最高分
	if is_new_best:
		SaveManager.high_score = level_score
	
	# 3. 先设置最高分 Label 的文本为旧的分数
	best_label.text = "%d" % old_best_score
	
	# 如果本次得分为0，则无需滚动，直接设置为0并返回
	if level_score == 0:
		score_label.text = "0"
		return

	# 4. 创建一个新的 Tween 用于动画序列
	var roll_tween = create_tween()
	# 将动画链起来，这样它们会按顺序播放
	roll_tween.set_parallel(false)
	
	# 定义滚动动画的持续时间
	var roll_duration: float = 1.2

	# 5. 第一个动画：滚动当前分数
	roll_tween.tween_method(
		func(value: float): score_label.text = "%d" % int(value),
		0.0,
		float(level_score),
		roll_duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# 6. 如果是新纪录，在分数滚动完毕后执行庆祝动画
	if is_new_best:
		# 使用 tween_callback 在上一个动画结束后执行逻辑
		roll_tween.tween_callback(func():
			# 更新 Best Label 的文本和外观
			best_label.text = "%d" % SaveManager.high_score
			best_label.modulate = Color.GOLD # 让它变金黄色，更醒目！
			
			# 创建一个独立的Tween来播放弹跳动画，可以与音效等并行
			var pop_tween = create_tween()
			var pop_duration = 0.2
			# 放大
			pop_tween.tween_property(best_label, "scale", Vector2(1.5, 1.5), pop_duration) \
					 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			# 带回弹效果地恢复原状
			pop_tween.tween_property(best_label, "scale", Vector2.ONE, pop_duration * 1.5) \
					 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		)

var jump_duration: float = 0.5
var tween: Tween
func jump_out() -> void:
	# 如果上一个动画还在播放，先杀掉它，防止冲突
	if tween and tween.is_running():
		tween.kill()

	scale = Vector2.ZERO
	# 创建新的 Tween
	tween = get_tree().create_tween()
	
	tween.tween_property(self, "scale", Vector2.ONE, jump_duration) \
		 .set_trans(Tween.TRANS_BACK) \
		 .set_ease(Tween.EASE_OUT)
	tween.finished.connect(_label_roll_number)
	await tween.finished

func jump_back() -> void:
	if tween and tween.is_running():
		tween.kill()
		
	scale = Vector2.ONE
	tween = get_tree().create_tween()
	
	# 收回时，使用 TRANS_BACK 和 EASE_IN 会有一种“吸入”感，效果很棒
	# 它会先稍微变大一点，然后猛地缩小
	tween.tween_property(self, "scale", Vector2.ZERO, jump_duration * 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
