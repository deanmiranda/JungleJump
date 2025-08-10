extends Area2D
class_name Item

signal picked_up

var textures = {
	"cherry": "res://assets/sprites/cherry.png",
	"gem": "res://assets/sprites/gem.png"
}

func init (type, _position):
	$Sprite2D.texture = load(textures[type])
	position = _position

# This signal is probably wrong! page 112 says on item body entered but I couldn't use that
func _on_body_entered(_body: Node2D) -> void:
	picked_up.emit()
	$ItemSound.play()
	queue_free()
