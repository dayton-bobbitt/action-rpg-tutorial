extends KinematicBody2D


enum State {
	IDLE,
	MOVE,
	ROLL,
	ATTACK
}

const ANIMATION = {
	IDLE = "Idle",
	MOVE = "Move",
	ROLL = "Roll",
	ATTACK = "Attack"
}
const ANIMATION_BLEND_POSITION_PARAM = "parameters/%s/blend_position"
const INPUT = {
	LEFT = "ui_left",
	RIGHT = "ui_right",
	UP ="ui_up",
	DOWN = "ui_down",
	ROLL = "ui_roll",
	ATTACK = "ui_attack"
}
const DEFAULT_MAX_SPEED: int = 75
const ROLLING_MAX_SPEED: int = 100
const DEFAULT_ACCELERATION: int = 15
const ROLLING_ACCELERATION: int = 50
const DEFAULT_FRICTION: int = 15
const ATTACK_FRICTION: int = 5

var _state = State.IDLE
var _direction = Vector2.ZERO
var _velocity = Vector2.ZERO

onready var _animation_tree = $AnimationTree
onready var _animation_tree_playback = _animation_tree.get("parameters/playback")
onready var _attack_cooldown_timer = $AttackCooldownTimer


func _ready():
	_animation_tree.active = true


func _process(_delta) -> void:
	# Do not allow player to change directions while rolling
	if not _is_rolling():
		_update_direction()
	
	_update_state()


func _physics_process(_delta) -> void:
	match _state:
		State.IDLE:
			_idle_state()
		State.MOVE:
			_move_state()
		State.ROLL:
			_roll_state()
		State.ATTACK:
			_attack_state()


func _update_direction() -> void:
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength(INPUT.RIGHT) - Input.get_action_strength(INPUT.LEFT)
	direction.y = Input.get_action_strength(INPUT.DOWN) - Input.get_action_strength(INPUT.UP)
	
	_direction = direction.normalized()


func _is_moving() -> bool:
	return _direction != Vector2.ZERO


func _is_attacking() -> bool:
	var is_currently_attacking = _state == State.ATTACK
	
	if is_currently_attacking:
		return true
	elif _attack_cooldown_timer.is_stopped() and Input.is_action_just_pressed(INPUT.ATTACK):
		_attack_cooldown_timer.start()
		return true
	else:
		return false


func _is_rolling() -> bool:
	var is_currently_rolling = _state == State.ROLL
	
	if is_currently_rolling:
		return true
	else:
		# Only allow roll if player is moving
		return _is_moving() && Input.is_action_just_pressed(INPUT.ROLL)


func _update_state() -> void:
	if _is_rolling():
		_state = State.ROLL
	elif _is_attacking():
		_state = State.ATTACK
	elif _is_moving():
		_state = State.MOVE
	else:
		_state = State.IDLE


func _idle_state() -> void:
	_stop_moving()
	_animation_tree_playback.travel(ANIMATION.IDLE)


func _move_state() -> void:
	_update_animation_blend_position()
	_move()
	_animation_tree_playback.travel(ANIMATION.MOVE)


func _roll_state() -> void:
	_move(ROLLING_MAX_SPEED, ROLLING_ACCELERATION)
	_animation_tree_playback.travel(ANIMATION.ROLL)


func _attack_state() -> void:
	_stop_moving(ATTACK_FRICTION)
	_animation_tree_playback.travel(ANIMATION.ATTACK)


# Increase velocity by acceleration until max_speed
func _move(max_speed := DEFAULT_MAX_SPEED, acceleration := DEFAULT_ACCELERATION) -> void:
	var new_velocity = _velocity.move_toward(_direction * max_speed, acceleration)
	_velocity = move_and_slide(new_velocity)


# Reduce velocity by friction until zero
func _stop_moving(friction := DEFAULT_FRICTION) -> void:
	var new_velocity = _velocity.move_toward(Vector2.ZERO, friction)
	_velocity = move_and_slide(new_velocity)


func _update_animation_blend_position() -> void:
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.IDLE, _direction)
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.MOVE, _direction)
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.ROLL, _direction)
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.ATTACK, _direction)


func _roll_animation_finished() -> void:
	_state = State.IDLE


func _attack_animation_finished() -> void:
	_state = State.IDLE
