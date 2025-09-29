class_name Bomb
extends Actor

func _ready() -> void:
	_gravity = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY)
	$AnimationPlayer.play(&"explodonate")

func _physics_process(delta: float) -> void:
	velocity.y += _gravity * delta
	velocity.x = lerp(0.0, velocity.x, pow(0.5, delta * 2.0))
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal) * 0.5
		if normal.angle_to(Vector2.UP) < PI * 0.5 and velocity.y < -50.0:
			velocity.y = 0.0

func get_desired_movement() -> Vector2:
	return Vector2.ZERO
	
func desires_jump() -> bool:
	return false

func detonate() -> void:
	$Explosion.visible = true
	$ExplosionArea.monitoring = true
	create_tween().tween_callback(func():
		get_parent().remove_child(self)
		queue_free()
	).set_delay(0.1)
	
func take_hit(_source: Actor) -> bool:
	return false

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_hit") and not body is Bomb:
		body.take_hit(self)
