extends DestructableStructure

var _invulnerable := false

func take_hit(source: Actor, from_weakspot := false) -> bool:
	if _invulnerable or not from_weakspot:
		return false
	if super.take_hit(source) and hit_points > 0:
		$Sprite2D.frame = 1
		_invulnerable = true
		create_tween().tween_callback(func():
			_invulnerable = false
			$Sprite2D.frame = 0
		).set_delay(0.1)
		return true
	return false

func explosion_scale(v: float) -> void:
	$ExplosionGroup/Explosion.scale = Vector2(v, v)
	$ExplosionGroup/Explosion2.scale = Vector2(v, v)
	$ExplosionGroup/Explosion3.scale = Vector2(v, v)
	

func destroy() -> void:
	_invulnerable = true
	$ExplosionGroup.visible = true
	var tween = create_tween()
	tween.tween_method(explosion_scale,
		0.0, 1.0, 0.1
	)
	tween.tween_callback(func(): $Sprite2D.frame = 3)
	tween.tween_method(explosion_scale,
		1.0, 0.0, 0.4
	).set_delay(0.3)
	Globals.change_state(Globals.GameState.WIN)
