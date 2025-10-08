extends Panel


func _ready() -> void:
	$AnimationPlayer.play("victory_dance")
	$RestartButton.visible = false
	$RestartButton.modulate = Color(1.0, 1.0, 1.0, 0.0)
	$RestartButton.grab_focus()
	var tween := create_tween()
	tween.tween_callback(func(): $RestartButton.visible = true).set_delay(1.0)
	tween.tween_property($RestartButton, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level1.tscn")
