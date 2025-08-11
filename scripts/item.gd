extends Area2D
class_name Item

signal picked_up

var textures = {
	"cherry": "res://assets/sprites/cherry.png",
	"gem": "res://assets/sprites/gem.png"
}

var item_type: String   

func init (type, _position):
	item_type = type
	$Sprite2D.texture = load(textures[type])
	position = _position

func _on_body_entered(_body: Node2D) -> void:
	picked_up.emit(item_type)  
	$ItemSound.play()
	queue_free()
