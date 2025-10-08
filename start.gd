extends Panel

var _original_positions := []

func _ready() -> void:
	_original_positions.resize(6)
	_original_positions[0] = $Building.position.y
	_original_positions[1] = $Building2.position.y
	_original_positions[2] = $Building3.position.y
	_original_positions[3] = $Building4.position.y
	_original_positions[4] = $Building5.position.y
	_original_positions[5] = $Building6.position.y
	$Building.position.y += 500
	$Building2.position.y += 500
	$Building3.position.y += 500
	$Building4.position.y += 500
	$Building5.position.y += 500
	$Building6.position.y += 500
	var tween = create_tween()
	tween.tween_method(func(x):
		var v = ease(x, -2.0)
		$Building.position.y  = _original_positions[0] + v * 500.0
		$Building2.position.y = _original_positions[1] + v * 570.0
		$Building3.position.y = _original_positions[2] + v * 630.0
		$Building4.position.y = _original_positions[3] + v * 700.0
		$Building5.position.y = _original_positions[4] + v * 400.0
		$Building6.position.y = _original_positions[5] + v * 360.0,
		1.0, 0.0, 1.0
	)
	$Label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	$StartButton.modulate = Color(1.0, 1.0, 1.0, 0.0)
	tween.parallel().tween_property($Label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5).set_delay(0.5)
	tween.parallel().tween_property($StartButton, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5).set_delay(0.75)
	
	$StartButton.grab_focus()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level1.tscn")
