extends Node

signal score_updated(new_score)

var num_levels = 3
var current_level = 0
var score = 0

var game_scene = "res://scenes/main.tscn"
var title_screen = "res://scenes/ui/title.tscn"

func restart():
	current_level = 0
	score = 0
	get_tree().change_scene_to_file(title_screen)

func next_level():
	current_level += 1
	print('next level ', current_level)
	if current_level <= num_levels:
		call_deferred("_go_game")

func _go_game() -> void:
	get_tree().change_scene_to_file(game_scene)
	
func increment_score():
	score += 1
	score_updated.emit(score)
