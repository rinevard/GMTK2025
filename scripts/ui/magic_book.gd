class_name MagicBook
extends Control

signal reading_finished()

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

const BOOK_ELE = preload("res://assets/art/ui/new-book/book-ele.png")
const BOOK_HEAL = preload("res://assets/art/ui/new-book/book-heal.png")
const BOOK_MIRROR = preload("res://assets/art/ui/new-book/book-mirror.png")
const BOOK_SLOW = preload("res://assets/art/ui/new-book/book-slow.png")
var books: Array[Resource] = [
BOOK_SLOW, BOOK_ELE, BOOK_MIRROR, BOOK_HEAL
]
@onready var book: TextureRect = $Book

func set_book(book_num: int) -> void:
	book.texture = books[book_num % books.size()]

func _on_confirm_pressed() -> void:
	reading_finished.emit()
