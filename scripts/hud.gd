extends MarginContainer

@onready var life_counter = $HBoxContainer/LifeCounter.get_children()
@onready var score_label = $HBoxContainer/Score

func _ready():
	update_score(GameState.score)
	GameState.score_updated.connect(update_score)
	
func update_life(value):
	for heart in life_counter.size():
		life_counter[heart].visible = value > heart
		
func update_score(value):
	score_label.text = str(value)
	
