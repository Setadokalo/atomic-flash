@abstract
class_name Actor
extends CharacterBody2D

signal actor_hit
signal actor_died

enum State {
	NORMAL,
	INACTIVE,
	DYING,
	HIT,
	# Custom everything, just process move_and_slide
	CUSTOM
}

const COYOTE_THRESHOLD := 0.05
const JUMPHOLD_DURATION := 0.25

@export
var movement_speed := 200.0

@export
var allow_player_damage := true

@export
var health := 1

@export var can_fly := false
## Fraction of gravity that applies when flying enemy is hit. 0 means no gravity at all, 1 means full strength gravity.
@export_range(0.0, 1.0, 0.01) var flying_gravity_when_hit := 1.0

@export_range(0.0, 10.0)
var post_hit_invulnerability := 0.0

var state = State.NORMAL
var state_transition_tween: Tween

var _air_time := 0.0
var _jump_boost := 0.0
var _jumping := false

var _invulnerability := 0.0

func _ready() -> void:
	state_transition_tween = create_tween()
	state_transition_tween.stop()

func _process(delta: float) -> void:
	if not can_fly:
		rotation = lerp_angle(-get_gravity().angle_to(Vector2.DOWN), rotation, pow(0.5, delta * 90.0))

func _physics_process(delta: float) -> void:
	if not get_gravity().is_zero_approx():
		up_direction = -get_gravity().normalized()
	_invulnerability -= delta
	var temp_velocity := velocity
	if not can_fly or state == State.HIT:
		temp_velocity += get_gravity() * delta * (flying_gravity_when_hit if can_fly else 1.0)
	temp_velocity = temp_velocity.rotated(-rotation)
	if state == State.NORMAL:
		var desire := get_desired_movement()
		temp_velocity.x = lerpf(desire.x * movement_speed, temp_velocity.x, pow(0.5, delta * 10.0))
		if not can_fly:
			temp_velocity = jump_logic(delta, desire, temp_velocity)
		else:
			temp_velocity.y = lerpf(desire.y * movement_speed, temp_velocity.y, pow(0.5, delta * 10.0))
	if state == State.HIT or state == State.DYING:
		temp_velocity.x = lerpf(0.0, temp_velocity.x, pow(0.5, delta * 10.0))
	temp_velocity = temp_velocity.rotated(rotation)
	# Apply half of delta-v before update then the other half after
	var deltav := temp_velocity - velocity
	velocity += deltav * 0.5
	move_and_slide()
	velocity += deltav * 0.5

func jump_logic(delta: float, desire: Vector2, temp_velocity: Vector2) -> Vector2:
	if not is_on_floor():
		if desire.y > -0.25:
			_jumping = false
		_air_time += delta
	else:
		_jumping = false
		_air_time = 0.0
		
	if (desires_jump() and not _jumping and _air_time < COYOTE_THRESHOLD)\
			or (_jumping and desire.y < -0.25 and _air_time < JUMPHOLD_DURATION + _jump_boost):
		if not _jumping:
			_jump_boost = clampf(abs(velocity.x / 500.0), 0.0, 0.1)
		_jumping = true
		temp_velocity.y = -225.0
		# Directly update velocity when setting to exact value
		velocity.y = -225.0
	return temp_velocity

@abstract
func get_desired_movement() -> Vector2

@abstract
func desires_jump() -> bool

func die() -> void:
	self.queue_free()

func take_hit(source: Actor) -> bool:
	# Can't take damage when invulnerable
	if _invulnerability > 0.0:
		print("hit during iframes")
		return false
	if state == State.DYING or source == Globals.player and not allow_player_damage:
		return false
	health -= 1
	if state != State.CUSTOM:
		state = State.HIT
		state_transition_tween.kill()
		state_transition_tween = create_tween()
		state_transition_tween.tween_callback(func(): state = State.NORMAL).set_delay(0.5)
	if source != null:
		velocity = Vector2(sign(global_position.x - source.global_position.x) * 50.0, -25.0)
	else:
		velocity = Vector2(sign(-velocity.x) * 50.0, -25.0)
	_invulnerability = post_hit_invulnerability
	actor_hit.emit()
	if health <= 0:
		state = State.DYING
		state_transition_tween.kill()
		die()
		actor_died.emit()
	return true


func hit(target: Actor) -> void:
	target.take_hit(self)
	print(name, " hit ", target.name)

func set_state(new_state: State) -> void:
	state = new_state
