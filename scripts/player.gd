extends CharacterBody2D

signal life_changed
signal died

@export var gravity = 450
@export var run_speed = 150
@export var jump_speed = -200
@export var max_jumps = 2
@export var double_jump_factor = .75
@export var climb_speed = 100
@export var fall_death_y = 1000 

enum { IDLE, HURT, RUN, CROUCH, JUMP, CLIMB, DEAD }

var state = IDLE
var life = 3: set = set_life
var jump_count = 0
var is_on_ladder = false

func _ready():
	change_state(IDLE)

func change_state(new_state):
	state = new_state
	match new_state:
		IDLE:
			$AnimationPlayer.play('idle')
		HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			if state == HURT and life > 0:   # <- guard
				change_state(IDLE)
		RUN:
			$AnimationPlayer.play('run')
		JUMP:
			$AnimationPlayer.play('jump_up')
			jump_count = 1
		CLIMB:
			$AnimationPlayer.play('climb')
		CROUCH:
			$AnimationPlayer.play('crouch')
		DEAD:
			died.emit()
			hide()
			velocity = Vector2.ZERO
			set_physics_process(false)
			if GameState.lives_remaining <= 0:
				$GameOverMusic.play()

func get_input():
	# Prevent input if player is hurt or dead
	if state == HURT or state == DEAD:
		return

	# Read player inputs
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var up = Input.is_action_pressed('climb')
	var down = Input.is_action_pressed('crouch')
	
	# Reset horizontal movement each frame
	velocity.x = 0

	# --- CLIMB state logic ---
	# If pressing UP and on a ladder, switch to CLIMB state
	if up and state != CLIMB and is_on_ladder:
		change_state(CLIMB)
		
	# Movement while in CLIMB state
	if state == CLIMB:
		if up:
			velocity.y = -climb_speed
			$AnimationPlayer.play("climb")
		elif down:
			velocity.y = climb_speed
			$AnimationPlayer.play("crouch") 
		else:
			velocity.y = 0
			$AnimationPlayer.stop()
	# Exit CLIMB state if no longer on a ladder
	if state == CLIMB and not is_on_ladder:
		change_state(IDLE)
		
	# Maintain / exit CROUCH
	if state == CROUCH:
		if not down:
			change_state(IDLE)
		else:
			velocity.x = 0
			return


	# --- RUN/IDLE state logic ---
	# Handle horizontal movement
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true

	# --- JUMP state logic ---
	# Handle mid-air extra jumps (e.g., double jump)
	if jump and state == JUMP and jump_count < max_jumps and jump_count > 0:
		$JumpSound.play()
		$AnimationPlayer.play("jump_up")
		velocity.y = jump_speed / double_jump_factor
		jump_count += 1
	# Handle normal jump from ground
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed

	# Switch between IDLE and RUN depending on movement
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)

	# Switch to JUMP state if walking/running off a ledge
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)

	# --- CROUCH state logic ---
	if down and is_on_floor():
		if state != CROUCH:
			change_state(CROUCH)
		velocity.x = 0
		return
		
var _stomped_this_frame := false

func _physics_process(delta):
	_stomped_this_frame = false
	if state == DEAD: return
	get_input()
	move_and_slide()

	if state != CLIMB:
		velocity.y += gravity * delta
	if state == HURT: return

	for i in range(get_slide_collision_count()):
		var c := get_slide_collision(i)
		var col := c.get_collider()

		if col.is_in_group("danger") and not _stomped_this_frame:
			hurt()
		elif col.is_in_group("enemies") and not _stomped_this_frame:
			if col.has_method("take_damage"):
				if velocity.y <= 0: 
					hurt()
			else:
				hurt()
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		jump_count = 0
		$Dust.emitting = true
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play('jump_down')
		# Check for fall death
	if global_position.y >= fall_death_y:
		set_life(0)
		return
		

func _on_StompZone_area_entered(area: Area2D) -> void:
	if velocity.y > 50 and area.is_in_group("enemy_head"):
		_stomped_this_frame = true
		var enemy := area.get_parent()
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage()
		velocity.y = -200.0

func reset(_position):
	life = 3
	position = _position
	velocity = Vector2.ZERO
	show()
	set_physics_process(true)
	change_state(IDLE)

func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0 and state != DEAD:
		change_state(DEAD)

func hurt():
	if state != HURT:
		change_state(HURT)
		$HurtSound.play()
		var cam := get_node_or_null("Camera2D")
		if cam and cam.has_method("start_shake"):
			cam.start_shake(6.0, 0.18)

func _on_door_body_entered(_body):
	pass
	
func heal(amount: int = 1) -> void:
	set_life(life + amount)
