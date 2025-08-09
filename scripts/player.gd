extends CharacterBody2D

@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300

enum { IDLE, HURT, RUN, JUMP, DEAD }

var state = IDLE

func _ready():
	change_state(IDLE)

func change_state(new_state):
	state = new_state
	match new_state:
		IDLE:
			$AnimationPlayer.play('idle')
			$CollisionShape2D.set_deferred("disabled", false)
		HURT:
			$AnimationPlayer.play('hurt')
			$CollisionShape2D.set_deferred("disabled", true)
		RUN:
			$AnimationPlayer.play('run')
			$CollisionShape2D.set_deferred("disabled", false)
		JUMP:
			$AnimationPlayer.play('jump_up')
			$CollisionShape2D.set_deferred('disabled', false)
		DEAD:
			hide()
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state
	
func get_input():
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_pressed("jump")
	
	velocity.x = 0
	
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)
		

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	
	move_and_slide()
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play('jump_down')
	
func reset(_position):
	position = _position
	show()
	change_state(IDLE)
