extends Camera2D

@export var target: Node2D

@export var death_plane: Area2D

var _player_alive := true

func _ready() -> void:
	Globals.player.respawned.connect(on_player_respawn)
	Globals.player.actor_died.connect(func(): 
		death_plane.global_position.y = 10000000.0
		_player_alive = false
	)

func _process(_delta: float) -> void:
	if target:
		global_position = target.global_position
		if death_plane and _player_alive:
			var bottom_of_screen: float = get_screen_center_position().y + get_viewport().get_visible_rect().size.y / 2.0
			death_plane.global_position.y = bottom_of_screen + 30.0
			limit_bottom = mini(limit_bottom, bottom_of_screen as int + 15)

func on_player_respawn() -> void:
	var bottom_of_screen: float = Globals.player.respawn_position.y + get_viewport().get_visible_rect().size.y / 2.0
	global_position = Globals.player.respawn_position
	death_plane.global_position.y = bottom_of_screen + 30.0
	limit_bottom = bottom_of_screen as int
	print(bottom_of_screen)
	(func(): _player_alive = true).call_deferred()
	align()
