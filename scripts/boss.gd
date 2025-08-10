extends CharacterBody2D
class_name Boss

signal died

@export var max_life: int = 2
@export var speed: float = 120.0
@export var swoop_speed: float = 260.0
@export var projectile_scene: PackedScene
@export var arena_left: float = -200.0
@export var arena_right: float = 200.0

enum { INTRO, IDLE, SWOOP, SHOOT, STUNNED, DEAD }
var state: int = INTRO
var life: int = max_life
var player: Node2D

func _ready() -> void:
	add_to_group("boss")
	player = get_tree().get_first_node_in_group("player") # Player must be in "player" group
	change_state(INTRO)
	
func change_state(s: int) -> void:
	state = s
	match s:
		INTRO:
			$AnimationPlayer.play("idle")
			$AttackTimer.start(1.0)
		IDLE:
			$AnimationPlayer.play("idle")
			$AttackTimer.start(randf_range(0.6, 1.2))
		SWOOP:
			$AnimationPlayer.play("swoop")
			$AttackTimer.stop()
		SHOOT:
			$AnimationPlayer.play("mount_attack") # make sure this clip is NON-looping
			$AttackTimer.stop()
			_start_shoot()
		STUNNED:
			$AnimationPlayer.play("hurt")
			$AttackTimer.start(0.8)
		DEAD:
			died.emit()
			$HurtBox/CollisionShape2D.set_deferred("disabled", true)
			$AnimationPlayer.play("die")

func _physics_process(delta: float) -> void:
	match state:
		SWOOP:
			_do_swoop(delta)
	if state != DEAD:
		move_and_slide()

func _on_AttackTimer_timeout() -> void:
	if state in [INTRO, STUNNED]:
		change_state(IDLE)
		return
	if state == IDLE:
		if randi() % 2 == 0:
			change_state(SWOOP)
		else:
			change_state(SHOOT)

# Wind-up → fire burst (attack) → back to idle
func _start_shoot() -> void:
	if state != SHOOT:
		return
	# wait for mount_attack to finish (ensure it’s non-looping)
	await $AnimationPlayer.animation_finished
	if state != SHOOT:
		return
	$AnimationPlayer.play("attack") # play during the burst (can be looping)
	await _do_shoot_burst()
	if state != DEAD:
		change_state(IDLE)

func _do_swoop(delta: float) -> void:
	if player == null:
		change_state(IDLE)
		return
	var target_x: float
	if global_position.x > 0.0:
		target_x = arena_left
	else:
		target_x = arena_right
	var dir := Vector2(target_x - global_position.x, player.global_position.y - global_position.y).normalized()
	velocity = dir * swoop_speed
	var reached_left := (target_x == arena_left and global_position.x <= arena_left)
	var reached_right := (target_x == arena_right and global_position.x >= arena_right)
	if reached_left or reached_right:
		velocity = Vector2.ZERO
		change_state(IDLE)

func _do_shoot_burst() -> void:
	if projectile_scene == null or player == null:
		return
	var shots := 3
	for i in range(shots):
		var p: Node2D = projectile_scene.instantiate() as Node2D
		get_parent().add_child(p)
		p.global_position = $Muzzle.global_position
		if p.has_method("launch_toward"):
			p.call("launch_toward", player.global_position)
		await get_tree().create_timer(0.15).timeout

func take_damage(amount: int = 1) -> void:
	if state == DEAD:
		return
	life -= amount
	$AnimationPlayer.play("hurt")
	if life <= 0:
		change_state(DEAD)
	else:
		change_state(STUNNED)

# Hitbox (hurts player)
func _on_Hitbox_body_entered(body: Node) -> void:
	if state == DEAD:
		return
	if body.is_in_group("player"):
		body.call("hurt")

# Hurtbox (player can stomp/attack)
func _on_Hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.global_position.y < global_position.y - 8.0 and body.velocity.y > 0.0:
			take_damage(1)
			body.velocity.y = -200.0
