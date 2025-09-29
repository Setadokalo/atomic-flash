extends Node2D
@export
var time_to_complete = 30.99

@export_file_path("*.tscn")
var next_level: String

var _restart_hold_timer := 0.0

func _ready() -> void:
	Globals.time_to_complete = time_to_complete
	Globals.change_state(Globals.GameState.ACTIVE)

func _process(delta: float) -> void:
	if Input.is_action_pressed("restart_level"):
		_restart_hold_timer += delta
	else:
		_restart_hold_timer = 0.0
	if _restart_hold_timer > 1.0:
		get_tree().reload_current_scene()

func _on_ui_requested_next() -> void:
	# Shouldn't be possible, but no sense in not preventing it
	if Globals.state != Globals.GameState.WIN:
		return
	get_tree().change_scene_to_file(next_level)

func _on_ui_requested_quit() -> void:
	# TODO: Change this to go to main menu once I... have one...
	get_tree().quit()

func _on_ui_requested_retry() -> void:
	get_tree().reload_current_scene()
