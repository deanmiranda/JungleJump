extends Area2D
class_name Item

signal picked_up

var textures = {
	"cherry": "res://assets/sprites/cherry.png",
	"gem": "res://assets/sprites/gem.png"
}

const SFX := {
	"cherry": preload("res://assets/audio/pickups/cherry.ogg"),
	"gem":    preload("res://assets/audio/pickups/gem.ogg"),
	"default": preload("res://assets/audio/pickups/pickup_default.ogg"),
}

var item_type: String   

func init (type, _position):
	item_type = type
	$Sprite2D.texture = load(textures[type])
	position = _position

func _on_body_entered(_body: Node2D) -> void:
	# choose stream based on item_type
	var stream: AudioStream = SFX.get(item_type, SFX.get("default"))
	if stream:
		var s := AudioStreamPlayer2D.new()
		s.stream = stream
		s.bus = "SFX"
		get_tree().current_scene.add_child(s)
		s.global_position = global_position
		s.finished.connect(func(): s.queue_free())
		s.play()

	picked_up.emit(item_type)
	queue_free()
