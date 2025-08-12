extends Node

signal score_updated(new_score)
signal lives_updated(new_lives)

var num_levels = 5
var current_level = 0
var score = 0
var game_scene = "res://scenes/main.tscn"
var title_screen = "res://scenes/ui/title.tscn"
var starting_lives: int = 3
var lives_remaining: int = starting_lives

var _run_initialized: bool = false

func ensure_run_initialized() -> void:
	if not _run_initialized:
		lives_remaining = starting_lives
		score = 0
		_run_initialized = true
		lives_updated.emit(lives_remaining)
		score_updated.emit(score)

func restart():
	current_level = 0
	score = 0
	lives_remaining = starting_lives
	_run_initialized = false
	lives_updated.emit(lives_remaining)
	get_tree().change_scene_to_file(title_screen)

func next_level():
	current_level += 1
	if current_level <= num_levels:
		call_deferred("_go_game")

func restart_level():
	call_deferred("_go_game")

func _go_game() -> void:
	ensure_run_initialized()
	get_tree().change_scene_to_file(game_scene)

func increment_score():
	score += 1
	score_updated.emit(score)

func consume_life() -> bool:
	if lives_remaining > 1:
		lives_remaining -= 1
		lives_updated.emit(lives_remaining)
		return true
	lives_remaining = 0
	lives_updated.emit(lives_remaining)
	return false
