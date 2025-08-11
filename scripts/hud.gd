extends MarginContainer

@onready var life_counter = $VBoxContainer/HBoxContainer/LifeCounter.get_children()
@onready var score_label = $VBoxContainer/HBoxContainer/Score
@onready var game_over_label = $VBoxContainer/HBoxContainer2/GameOver
@onready var lives_label = $VBoxContainer2/HBoxContainer.get_node_or_null("Lives")

func _ready():
	hide_game_over()
	update_score(GameState.score)
	GameState.score_updated.connect(update_score)

	_update_lives_display(GameState.lives_remaining)
	if GameState.lives_updated.is_connected(_update_lives_display) == false:
		GameState.lives_updated.connect(_update_lives_display)

func update_life(value):
	for heart in life_counter.size():
		life_counter[heart].visible = value > heart

func update_score(value):
	score_label.text = str(value)

func _update_lives_display(value: int) -> void:
	if lives_label:
		lives_label.text = "x" + str(value)

func show_game_over():
	game_over_label.visible = true

func hide_game_over():
	game_over_label.visible = false

func show_life_lost():
	var life_lost := $VBoxContainer2/HBoxContainer2.get_node_or_null("LifeLost")
	if life_lost:
		life_lost.visible = true
		var t := create_tween()
		t.tween_interval(1.0).finished.connect(func(): life_lost.visible = false)
