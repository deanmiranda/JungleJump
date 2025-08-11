extends Camera2D

var _shake_time: float = 0.0
var _shake_duration: float = 0.0
var _shake_intensity: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _base: Vector2 = Vector2.ZERO
@export var use_offset: bool = true  

func _ready() -> void:
	_rng.randomize()
	if use_offset:
		_base = offset
	else:
		_base = position

func start_shake(intensity: float = 12.0, duration: float = 0.35) -> void:
	_shake_duration = max(duration, 0.001)
	_shake_time = _shake_duration
	_shake_intensity = intensity

func _process(delta: float) -> void:
	if _shake_time <= 0.0:
		return

	_shake_time -= delta
	var t: float = float(max(_shake_time / _shake_duration, 0.0))
	var amp: float = _shake_intensity * t 

	var dir: Vector2 = Vector2(
		_rng.randf_range(-1.0, 1.0),
		_rng.randf_range(-1.0, 1.0)
	)
	if dir.length() > 0.0:
		dir = dir.normalized()

	var jitter: Vector2 = dir * amp

	if use_offset:
		offset = _base + jitter
	else:
		position = _base + jitter

	if _shake_time <= 0.0:
		# reset to base
		if use_offset:
			offset = _base
		else:
			position = _base
