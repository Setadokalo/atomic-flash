extends Panel


func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused
		$VBoxContainer/CONTINUE.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false
