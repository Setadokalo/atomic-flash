extends CanvasLayer

signal requested_retry
signal requested_next
signal requested_quit

func set_gameover_text(text: String) -> void:
	%GameOverText.text = text

func get_gameover_label() -> Label:
	return %GameOverText


func _ready() -> void:
	# TODO: A main menu makes this unnecessary
	if OS.get_name() == "Web":
		$VBoxContainer/GameOverButtonClip/GameOverButtonBox/QuitButton.visible = false
	%GameOverText.visible_ratio = 0.0
	$GameOverFlash.visible = false
	%GameOverButtonClip.custom_minimum_size = Vector2.ZERO
	Globals.game_state_changed.connect(on_game_state_changed)
	Globals.player.respawned.connect(func():
		$RestartTip.visible = true
		$RestartTip.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var tween := create_tween()
		tween.tween_property($RestartTip, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
		tween.tween_property($RestartTip, "modulate", Color(1.0, 1.0, 1.0, 0.0), 3.0).set_delay(3.0)
	)

func on_game_state_changed() -> void:
	if Globals.state == Globals.GameState.LOSE:
		%NextButton.visible = false
		$GameOverFlash.visible = true
		set_gameover_text("YOU DID NOT\nSTOP THE APOCALYPSE")
		var tween = create_tween()
		$GameOverFlash.color = Color(1.0, 1.0, 1.0, 0.0)
		tween.tween_property($GameOverFlash, "color", Color(1.0, 1.0, 1.0, 1.0), 0.0625)
		tween.tween_property($GameOverFlash, "color", Color(1.0, 1.0, 1.0, 0.0), 1.0).set_delay(1.0)
		tween.tween_property(%GameOverText, "visible_ratio", 1.0, 2.0)
		tween.tween_callback(func(): $GameOverFlash.color = Color("#00000000"))
		tween.tween_property($GameOverFlash, "color", Color("#000000FF"), 2.0).set_delay(1.0)
		tween.parallel().tween_property(%GameOverButtonClip, "custom_minimum_size", Vector2(0.0, 32.0), 0.5).set_delay(0.5)
	
	elif Globals.state == Globals.GameState.WIN:
		%NextButton.visible = true
		$GameOverFlash.visible = true
		set_gameover_text("APOCALYPSE\nPREVENTED")
		var tween = create_tween()
		tween.tween_property(%GameOverText, "visible_ratio", 1.0, 1.0)
		$GameOverFlash.color = Color("#00000000")
		tween.tween_property(%GameOverButtonClip, "custom_minimum_size", Vector2(0.0, 32.0), 0.5).set_delay(1.0)
		tween.tween_property($GameOverFlash, "color", Color("#000000FF"), 2.0).set_delay(1.0)

func _process(_delta: float) -> void:
	if Globals.state == Globals.GameState.ACTIVE:
		$TimeRemaining.text = String.num_int64(int(maxf(floorf(Globals.time_to_complete), 0.0)))


func _on_retry_button_pressed() -> void:
	requested_retry.emit()


func _on_next_button_pressed() -> void:
	requested_next.emit()


func _on_quit_button_pressed() -> void:
	requested_quit.emit()
