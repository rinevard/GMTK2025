extends Node

# 1. 需要保存的数据
var high_score: int = 0
var books_seen_count: int = 0

# 存档路径，用 .cfg 后缀更符合它的格式
const SAVE_PATH = "user://save.cfg"

# 游戏启动时自动加载
func _ready():
	load_game()

func save_game():
	var config = ConfigFile.new()
	high_score = max(high_score, PlayerRelatedData.level_score)
	# 在一个叫做 "PlayerData" 的分区下，保存我们的数据
	config.set_value("PlayerData", "high_score", high_score)
	config.set_value("PlayerData", "books_seen", books_seen_count)
	
	# 一行代码搞定保存
	var err = config.save(SAVE_PATH)
	if err != OK:
		printerr("保存文件失败!")
	else:
		print("游戏已保存。最高分: ", high_score)

# 3. 加载功能 (同样简单)
func load_game():
	var config = ConfigFile.new()
	
	# 尝试加载文件，如果文件不存在，load会失败，但这没关系
	var err = config.load(SAVE_PATH)
	if err != OK:
		print("未找到存档文件，将使用默认值。")
		return

	# 加载数据，如果某个键不存在，就使用我们提供的默认值 (比如 0)
	high_score = config.get_value("PlayerData", "high_score", 0)
	books_seen_count = config.get_value("PlayerData", "books_seen", 0)
	
	print("游戏已加载。最高分: ", high_score)
