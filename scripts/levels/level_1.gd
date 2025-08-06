extends Level

var spwan_gap: float = 3.0
var time_after_last_spawn: float = 3.0
var level_end: bool = false

func _ready() -> void:
	super._ready()
	PlayerRelatedData.player_lose.connect(_on_player_lose)

func _process(delta: float) -> void:
	level_time += delta
	# 关卡结束就不做事情了
	if level_end or PlayerRelatedData.level_paused:
		return
	
	duration -= delta
	if duration < 0.0:
		level_end = true
		enemy_handler.clear_enemies()
		bullet_handler.clear_bullets()
		level_completed.emit(level_num)
	
	time_after_last_spawn += delta
	if time_after_last_spawn >= spwan_gap:
		enemy_handler.spawn_enemy()
		time_after_last_spawn = 0.0

func _on_player_lose() -> void:
	enemy_handler.clear_enemies()
	bullet_handler.clear_bullets()
	dropped_handler.clear_dropped()
