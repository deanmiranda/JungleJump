extends Node2D

var item_scene = load("res://scenes/items/item.tscn")
var door_scene = load("res://scenes/items/door.tscn")
var level_transition_started = false
var cherry_count: int = 0
var boss_ref: Boss = null
var boss_door: Area2D = null 

func _ready():
	$Music.play()
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	set_camera_limits()
	boss_ref = get_tree().get_first_node_in_group("boss") as Boss  # <-- replace your lookup
	spawn_items()
	create_ladders()
	if boss_ref:
		boss_ref.died.connect(_on_boss_died)

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
			var door := door_scene.instantiate() as Area2D
			add_child(door)
			door.global_position = world_pos
			door.add_to_group("door")
			door.body_entered.connect(self._on_door_body_entered.bind(door))

			if boss_ref and boss_door == null:
				boss_door = door
				_set_boss_door_locked(true)
		else:
			var item := item_scene.instantiate() as Item
			add_child(item)
			item.init(t, world_pos)
			item.picked_up.connect(self._on_item_picked_up)

func _on_item_picked_up(t: String) -> void:
	GameState.increment_score()
	if t == "gem":
		$Player.heal(1)
	elif t == "cherry":
		cherry_count += 1
		if cherry_count % 10 == 0:
			$Player.heal(1)

func _on_player_died() -> void:
	$Music.stop()
	var parent_node = get_parent()
	var hud_node = get_node_or_null("CanvasLayer/HUD")
	hud_node.show_game_over()
	await get_tree().create_timer(2.5).timeout
	GameState.restart()
	
func _on_door_body_entered(_body: Node, door: Area2D) -> void:
	if level_transition_started:
		return
	# If there is a boss, only allow transition from the boss_door when it's unlocked
	if boss_ref:
		var is_boss_door := (door == boss_door)
		var locked := (boss_door == null) or (boss_door.visible == false) or (boss_door.monitoring == false)
		if not is_boss_door or locked:
			return
	level_transition_started = true
	GameState.next_level()

func _on_ladders_body_entered(body: Node2D) -> void:
	body.is_on_ladder = true

func _on_ladders_body_exited(body: Node2D) -> void:
	body.is_on_ladder = false

func create_ladders():
	var cells = $World.get_used_cells(0)
	for cell in cells:
		var data = $World.get_cell_tile_data(0, cell)
		if data.get_custom_data("special") == "ladder":
			var c = CollisionShape2D.new()
			$Ladders.add_child(c)
			c.position = $World.map_to_local(cell)
			var s = RectangleShape2D.new()
			s.size = Vector2(8, 16)
			c.shape = s

func _on_boss_died() -> void:
	if boss_door:
		_set_boss_door_locked(false)
		boss_door.modulate.a = 0.0
		boss_door.create_tween().tween_property(boss_door, "modulate:a", 1.0, 0.5)

func _set_boss_door_locked(locked: bool) -> void:
	if boss_door == null:
		return
	# Hide/show
	boss_door.visible = not locked
	print('boss door visible? ', boss_door.visible)
	# Stop/allow overlap signals
	boss_door.set_deferred("monitoring", not locked)
	# Disable/enable *all* CollisionShape2D / CollisionPolygon2D under the door
	for child in boss_door.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", locked)
		elif child is CollisionPolygon2D:
			(child as CollisionPolygon2D).set_deferred("disabled", locked)
	if locked:
		boss_door.collision_layer = 0
		boss_door.collision_mask = 0
	else:
		boss_door.collision_layer = 0
		boss_door.collision_mask = 1 << 1
