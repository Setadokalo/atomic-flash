class_name Player
extends Actor

signal respawned

const BULLET := preload("uid://cayp6t2cspyp")

@export
var gun_cooldown := 0.2

var respawn_position: Vector2
var _skip_physics := false
var _gun_cooldown := 0.0

@onready
var animation: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
func _init() -> void:
	Globals.player = self

func _ready() -> void:
	super._ready()
	respawn_position = global_position

# Test to make sure gameplay isn't overly affected by low framerates
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("testing_toggle_slow"):
		#Engine.physics_ticks_per_second = 6 if Engine.physics_ticks_per_second == 60 else 60

func _process(_delta: float) -> void:
	if _invulnerability > 0.0:
		$MainCharacter/Iframes.visible = true
		$MainCharacter/Iframes.color.a = 0.25 if int(_invulnerability * 4.0) % 2 == 0 else 0.5
	else:
		$MainCharacter/Iframes.visible = false
	#super._process(delta)
	if abs(get_desired_movement().x) > 0.1:
		$AnimationTree.set("parameters/normal/blend_position", 
			Input.get_vector("move_left", "move_right", "look_down", "look_up"))
	elif abs(velocity.x) < 10.0:
		$AnimationTree.set("parameters/normal/blend_position",
			Vector2(-0.01 if  $MainCharacter.flip_h else 0.01, Input.get_axis("look_down", "look_up")))
	else:
		$AnimationTree.set("parameters/normal/blend_position",
			Vector2(velocity.x / 100.0, Input.get_axis("look_down", "look_up")))
	#if not is_on_floor():
		#modulate = Color(1.0, 0.0, 0.0)
	#else:
		#modulate = Color(1.0, 1.0, 1.0)

func _physics_process(delta: float) -> void:
	_gun_cooldown -= delta
	if _skip_physics:
		return
	super._physics_process(delta)
	if Globals.state != Globals.GameState.ACTIVE:
		return
	if state == State.NORMAL and Input.is_action_just_pressed("fire_primary") and _gun_cooldown <= 0.0:
		var bullet: Bullet = BULLET.instantiate()
		bullet.rotation = Vector2(1.0 if not $MainCharacter.flip_h else -1.0, Input.get_axis("look_up", "look_down")).angle()
		bullet.source = self
		get_parent().add_child(bullet)
		bullet.global_position = global_position - Vector2(0.0, 13.0)
		_gun_cooldown = gun_cooldown

func _on_death_plane_body_entered(body: Node2D) -> void:
	if body != self:
		return
	die(true)


func get_desired_movement() -> Vector2:
	if Globals.state == Globals.GameState.ACTIVE:
		var lr = Input.get_axis("move_left", "move_right")
		var ud = Input.get_axis("jump", "crouch")
		return Vector2(lr, ud)
	return Vector2.ZERO

func desires_jump() -> bool:
	if Globals.state == Globals.GameState.ACTIVE:
		return Input.is_action_just_pressed("jump")
	return false

func die(offscreen := false) -> void:
	if offscreen:
		self.visible = false
		_skip_physics = true
	state = State.DYING
	animation.travel("hitstun")
	if Globals.state == Globals.GameState.ACTIVE:
		if not validate_spawnpoint(respawn_position):
			Globals.change_state(Globals.GameState.LOSE)
		else:
			var death_tween := create_tween()
			death_tween.tween_callback(respawn).set_delay(1.0)

func validate_spawnpoint(spawnpoint: Vector2) -> bool:
	$RayCast2D.global_position = spawnpoint + Vector2(0.0, -2.0)
	$RayCast2D.force_raycast_update()
	return $RayCast2D.is_colliding()
	

func respawn() -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	self.visible = true
	_skip_physics = false
	state = State.NORMAL
	animation.travel("normal")
	respawned.emit()
	_invulnerability = 2.0


func entered_checkpoint(body: Node2D, area: Area2D) -> void:
	print(body.name, " enetered checkpoint ", area.name)
	if body != self:
		return
	if respawn_position.y < area.global_position.y or not validate_spawnpoint(area.global_position):
		return
	respawn_position = area.global_position
