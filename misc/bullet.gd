class_name Bullet
extends CharacterBody2D

const EXPLOSION := preload("uid://b7w5xwoo7agyy")

var source: Actor = null

# Time before the bullet despawns
var _lifetime := 1.0

func _physics_process(delta: float) -> void:
	velocity = Vector2.RIGHT.rotated(global_rotation) * 500.0
	_lifetime -= delta
	if _lifetime <= 0.0:
		self.get_parent().remove_child(self)
		self.queue_free()
		return
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		if collider.has_method("take_hit"):
			if is_instance_valid(source):
				collider.take_hit(source)
			else:
				collider.take_hit(null)
		print("Bullet hit ", collider.name)
		var explosion := EXPLOSION.instantiate()
		self.get_parent().add_child(explosion)
		explosion.global_position = global_position
		self.get_parent().remove_child(self)
		self.queue_free()
