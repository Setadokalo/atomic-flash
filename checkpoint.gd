@tool
extends Area2D

@export
var checkpoint_width := 4:
	set(v):
		checkpoint_width = v
		update_size()

func _ready() -> void:
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	body_entered.connect(Globals.player.entered_checkpoint.bind(self))

func update_size() -> void:
	if not has_node("CollisionShape2D"):
		return
	$CollisionShape2D.shape.size = Vector2(18.0 * checkpoint_width, 90.0)
	$CollisionShape2D.position = Vector2(0.0 if checkpoint_width % 2 == 0 else 9.0, -45.0)
