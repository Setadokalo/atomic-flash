extends StaticBody2D

func take_hit(source: Actor) -> bool:
	return get_parent().take_hit(source, true)
