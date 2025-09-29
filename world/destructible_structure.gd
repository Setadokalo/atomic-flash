class_name DestructableStructure
extends Destructable

var _origin_pos: Vector2

func _ready() -> void:
	_origin_pos = global_position

func destroy() -> void:
	var destroy_tween := create_tween()
	destroy_tween.tween_method(func(d): global_position.x = _origin_pos.x + sin(d * 100.0), 0.0, 10.0, 10.0)
	destroy_tween.parallel().tween_method(func(y): global_position.y += y * y, 0.0, 6.0, 3.0).set_delay(1.0)
	destroy_tween.parallel().tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), 3.0).set_delay(2.0)
