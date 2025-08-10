extends MarginContainer

@onready var life_counter = $VBoxContainer/HBoxContainer/LifeCounter.get_children()
@onready var score_label = $VBoxContainer/HBoxContainer/Score
@onready var game_over_label = $VBoxContainer/HBoxContainer2/GameOver

func _ready():
	hide_game_over()
	update_score(GameState.score)
	GameState.score_updated.connect(update_score)
	
func update_life(value):
	for heart in life_counter.size():
		life_counter[heart].visible = value > heart
		
func update_score(value):
	score_label.text = str(value)
	
func show_game_over():
	print('printing game over visible true')
	game_over_label.visible = true
	
func hide_game_over():
	game_over_label.visible = false
	
