extends Sprite2D


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_parent().remove_child(self)
	queue_free()
