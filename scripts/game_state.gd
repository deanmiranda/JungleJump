extends Node

signal score_updated(new_score)
signal lives_updated(new_lives) # NEW

var num_levels = 5
var current_level = 0
var score = 0

var game_scene = "res://scenes/main.tscn"
var title_screen = "res://scenes/ui/title.tscn"

var starting_lives: int = 3         # NEW: total lives at the start of a run
var lives_remaining: int = starting_lives  # NEW: stocks left (after current life)

func restart():
	current_level = 0
	score = 0
	lives_remaining = starting_lives  # NEW: reset lives on full restart
	lives_updated.emit(lives_remaining)
	get_tree().change_scene_to_file(title_screen)

func next_level():
	current_level += 1
	if current_level <= num_levels:
		call_deferred("_go_game")

func _go_game() -> void:
	get_tree().change_scene_to_file(game_scene)

func increment_score():
	score += 1
	score_updated.emit(score)

# NEW: consume one life; return true if we should continue (respawn), false = game over
func consume_life() -> bool:
	lives_remaining = max(0, lives_remaining - 1)
	lives_updated.emit(lives_remaining)
	return lives_remaining > 0
