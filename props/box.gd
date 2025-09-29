extends Destructable


func _physics_process(delta: float) -> void:
	# Hack to get around Destructable inheriting Node2D
	var kself = self as Object as CharacterBody2D
	# Lazy hack
	kself.velocity.y += Globals.player._gravity * delta
	kself.velocity.x = lerp(0.0, kself.velocity.x, pow(0.5, delta * 20.0))
	kself.move_and_slide()
