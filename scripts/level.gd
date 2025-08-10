extends Node2D

var item_scene = load("res://scenes/items/item.tscn")
var door_scene = load("res://scenes/items/door.tscn")
var level_transition_started = false

func _ready():
	$Music.play()
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	set_camera_limits()
	spawn_items()
	
func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x
			
func spawn_items() -> void:
	var cells: Array[Vector2i] = $Items.get_used_cells(0)
	for cell in cells:
		var td: TileData = $Items.get_cell_tile_data(0, cell)
		if td == null:
			continue
		var t: String = td.get_custom_data("type")
		if t.is_empty():
			continue

		var world_pos: Vector2 = $Items.to_global($Items.map_to_local(cell))

		if t == "door":
			var door: Area2D = door_scene.instantiate() as Area2D
			add_child(door)
			door.global_position = world_pos
			door.body_entered.connect(self._on_door_body_entered)
		else:
			var item: Item = item_scene.instantiate() as Item
			add_child(item)
			item.init(t, world_pos)
			item.picked_up.connect(self._on_item_picked_up)

func _on_item_picked_up():
	GameState.increment_score()

func _on_player_died() -> void:
	$Music.stop()
	var parent_node = get_parent()
	var hud_node = get_node_or_null("CanvasLayer/HUD")
	hud_node.show_game_over()
	await get_tree().create_timer(2.5).timeout
	GameState.restart()
	
func _on_door_body_entered(_body):
	if not level_transition_started:
		level_transition_started = true
		GameState.next_level()
