class_name Destructable
extends Node2D

@export
var allow_player_damage := true
@export
var hit_points := 3


func take_hit(source: Actor) -> bool:
	if source == Globals.player and not allow_player_damage:
		return false
	hit_points -= 1
	if hit_points <= 0:
		destroy()
	return true

func destroy() -> void:
	queue_free()
