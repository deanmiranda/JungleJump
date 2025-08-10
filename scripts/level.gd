extends Node2D

signal score_changed
var item_scene = load("res://scenes/items/item.tscn")
var door_scene = load("res://scenes/items/door.tscn")

func _ready():
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	set_camera_limits()
	cleanup_invalid_item_cells();
	spawn_items()
	
func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x

func cleanup_invalid_item_cells() -> void:
	for cell in $Items.get_used_cells(0):
		if $Items.get_cell_tile_data(0, cell) == null:
			$Items.set_cell(0, cell, -1)  # clear
			
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
	GameState.restart()
	
func _on_door_body_entered(_body):
	GameState.next_level()
