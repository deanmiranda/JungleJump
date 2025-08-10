extends Node

func _ready():
	var level_num = str(GameState.current_level).pad_zeros(2)
	print('level_num ', level_num)
	
	var path = "res://scenes/levels/level_%s.tscn" % level_num
	print('path ', path)
	
	var level = load(path).instantiate()
	print('level ', level)
	add_child(level)
