extends Node

signal game_state_changed

enum GameState {
	ACTIVE,
	WIN,
	LOSE,
}

var player: Player

var time_to_complete := 30.0

var state = GameState.ACTIVE

func _ready() -> void:
	game_state_changed.connect(func():
		if state == GameState.LOSE:
			get_tree().call_group("living", "die")
	)

func _process(delta: float) -> void:
	if state != GameState.WIN:
		time_to_complete -= delta
	if time_to_complete <= 0.0 and state == GameState.ACTIVE:
		change_state(GameState.LOSE)

func change_state(new_state: GameState) -> void:
	state = new_state
	game_state_changed.emit()
