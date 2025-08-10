extends Area2D
@export var speed: float = 180.0
var vel: Vector2 = Vector2.ZERO

func launch_toward(target: Vector2) -> void:
	vel = (target - global_position).normalized() * speed

func _physics_process(delta: float) -> void:
	global_position += vel * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.call("hurt")
	queue_free()
