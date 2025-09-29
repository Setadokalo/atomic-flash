extends Actor

enum CopterState {
	SEEKING,
	PANIC,
	LOCKED_ON,
}

const DESIRED_ANGLES: Array[float] = [0.0, PI, PI / 2.0, PI / 4.0, 3.0 * PI / 4.0]

const BULLET := preload("uid://cayp6t2cspyp")

@export
var bullet_cooldown := 2.0

var copter_state := CopterState.SEEKING

var _bullet_cooldown := 1.0
var _panic_cooldown := INF

func _ready() -> void:
	super._ready()
	can_fly = true
	_gravity = 0.0
	$FlyPlayer.play("base_fly")
	state = State.INACTIVE

func get_to_player() -> Vector2:
	return (Globals.player.global_position + Vector2(0.0, -18.0)) - global_position

func get_nearest_angle() -> float:
	var to_player := get_to_player()
	var nearest_angle = INF
	var angle_to := to_player.angle()
	if angle_to < -PI / 4.0:
		angle_to = angle_to + TAU
	for angle in DESIRED_ANGLES:
		if abs(angle_to - angle) < abs(angle_to - nearest_angle):
			nearest_angle = angle
	return nearest_angle

func _process(_delta: float) -> void:
	var angle = get_nearest_angle()
	if angle < PI / 2.0:
		$GunSprite.flip_h = false
	else:
		$GunSprite.flip_h = true
		angle = PI - angle
	if is_zero_approx(angle):
		$GunSprite.frame = 0
	if is_equal_approx(angle, PI / 4.0):
		$GunSprite.frame = 1
	if is_equal_approx(angle, PI / 2.0):
		$GunSprite.frame = 2

func _physics_process(delta: float) -> void:
	_panic_cooldown -= delta
	if copter_state == CopterState.PANIC:
		if _panic_cooldown <= 0.0:
			copter_state = CopterState.SEEKING
	elif get_to_player().length_squared() > (250 * 250):
		copter_state = CopterState.SEEKING
	else:
		copter_state = CopterState.LOCKED_ON
	super._physics_process(delta)
	if state == State.NORMAL and copter_state == CopterState.LOCKED_ON:
		_bullet_cooldown -= delta
		if _bullet_cooldown <= 0.0:
			_bullet_cooldown = bullet_cooldown
			var bullet: Bullet = BULLET.instantiate()
			bullet.source = self
			bullet.collision_mask = 1 | 4
			add_sibling(bullet)
			bullet.global_position = global_position + Vector2(0.0, 6.0)
			bullet.rotation = get_nearest_angle()
	else:
		_bullet_cooldown = bullet_cooldown

func get_desired_movement() -> Vector2:
	if copter_state == CopterState.PANIC:
		return Vector2(0, 0)
	var to_player := get_to_player()
	if to_player.length_squared() > (100 * 100):
		return to_player.normalized()
	var angle_to := to_player.angle()
	if angle_to < -PI / 4.0:
		angle_to = angle_to + TAU
	var nearest_angle = get_nearest_angle()
	if abs(angle_to - nearest_angle) < PI / 256.0:
		return Vector2.ZERO
	if angle_to - nearest_angle < 0.0:
		return Vector2.UP.rotated(nearest_angle)
	return Vector2.DOWN.rotated(nearest_angle)

func desires_jump() -> bool:
	return false


func _on_screen_entered() -> void:
	if state == State.INACTIVE:
		state = State.NORMAL


func _on_player_on_me_sensor_body_entered(body: Node2D) -> void:
	if body != Globals.player:
		return
	copter_state = CopterState.PANIC
	_panic_cooldown = INF


func _on_player_on_me_sensor_body_exited(body: Node2D) -> void:
	if body != Globals.player:
		return
	_panic_cooldown = 0.5
