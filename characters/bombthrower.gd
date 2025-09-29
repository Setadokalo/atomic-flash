extends Actor

enum BomberState {
	NORMAL,
	THROWING_BOMB,
}

const BOMB := preload("uid://xujgmx4x360e")

@export var throw_delay := 3.0
@export var throw_timer_offset := 0.0

var bomber_state := BomberState.NORMAL

var _throw_timer := 0.0

func _ready() -> void:
	super._ready()
	$AnimationPlayer.play("run")
	_throw_timer = throw_delay - throw_timer_offset
	state = State.INACTIVE

func _physics_process(delta: float) -> void:
	if state == State.NORMAL:
		_throw_timer -= delta
		if _throw_timer < 0.0:
			$AnimationPlayer.play("throw_bomb")
			state = State.CUSTOM
			bomber_state = BomberState.THROWING_BOMB
			_throw_timer = throw_delay
	if not $ForwardFloor.is_colliding() or $ForwardWall.is_colliding():
		$Sprite.flip_h = not $Sprite.flip_h
		$ForwardFloor.position.x = -$ForwardFloor.position.x
		$ForwardWall.position.x = -$ForwardWall.position.x
		$ForwardWall.target_position.x = -$ForwardWall.target_position.x
	if state == State.CUSTOM:
		velocity.x = lerp(0.0, velocity.x, pow(0.5, delta * 10.0))
	super._physics_process(delta)

func _on_damage_box_body_entered(body: Node2D) -> void:
	if body is Actor:
		hit(body)

func get_desired_movement() -> Vector2:
	return Vector2(-1.0 if $Sprite.flip_h else 1.0, 0.0)

func desires_jump() -> bool:
	return false

func throw_bomb() -> void:
	var bomb: Bomb = BOMB.instantiate()
	bomb.velocity = Vector2(-200.0 if $Sprite.flip_h else 200.0, -200.0)
	get_parent().add_child(bomb)
	bomb.global_position = global_position - Vector2(0.0, 13.0)

func set_bomber_states(new_bstate: BomberState, new_state: State) -> void:
	bomber_state = new_bstate
	state = new_state

func _on_screen_entered() -> void:
	if state == State.INACTIVE:
		state = State.NORMAL
