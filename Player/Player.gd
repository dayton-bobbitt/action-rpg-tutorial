extends KinematicBody2D


enum State {
	IDLE,
	MOVE,
	ATTACK
}

const ANIMATION = {
	IDLE = "Idle",
	MOVE = "Move",
	ATTACK = "Attack"
}
const ANIMATION_BLEND_POSITION_PARAM = "parameters/%s/blend_position"
const INPUT = {
	LEFT = "ui_left",
	RIGHT = "ui_right",
	UP ="ui_up",
	DOWN = "ui_down",
	ATTACK = "ui_attack"
}
const MAX_SPEED: int = 75
const ACCELERATION: int = 15
const DEFAULT_FRICTION: int = 15
const ATTACK_FRICTION: int = 5

var _state = State.IDLE
var _velocity = Vector2.ZERO

onready var _animation_tree = $AnimationTree
onready var _animation_tree_playback = _animation_tree.get("parameters/playback")


func _ready():
	_animation_tree.active = true


func _physics_process(_delta):
	var direction = _get_direction()
	var is_moving = direction != Vector2.ZERO
	var is_attacking = _get_is_attacking()
	
	_update_state(is_attacking, is_moving)
	
	match _state:
		State.IDLE:
			_player_idle()
		State.MOVE:
			_player_move(direction)
		State.ATTACK:
			_player_attack()


# Returns a normalized vector based on player input
func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength(INPUT.RIGHT) - Input.get_action_strength(INPUT.LEFT)
	direction.y = Input.get_action_strength(INPUT.DOWN) - Input.get_action_strength(INPUT.UP)
	
	return direction.normalized()


func _get_is_attacking() -> bool:
	var is_currently_attacking = _state == State.ATTACK
	
	if is_currently_attacking:
		return true
	else:
		return Input.is_action_just_pressed(INPUT.ATTACK)


func _update_state(is_attacking: bool, is_moving: bool) -> void:
	if is_attacking:
		_state = State.ATTACK
	elif is_moving:
		_state = State.MOVE
	else:
		_state = State.IDLE


func _player_idle() -> void:
	_stop_moving()
	_animation_tree_playback.travel(ANIMATION.IDLE)


func _player_move(direction: Vector2) -> void:
	_update_animation_blend_position(direction)
	_move(direction)
	_animation_tree_playback.travel(ANIMATION.MOVE)


func _player_attack() -> void:
	_stop_moving(ATTACK_FRICTION)
	_animation_tree_playback.travel(ANIMATION.ATTACK)


# Increase velocity by ACCELERATION until MAX_SPEED
func _move(direction: Vector2) -> void:
	var new_velocity = _velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	_velocity = move_and_slide(new_velocity)


# Reduce velocity by friction until zero
func _stop_moving(friction := DEFAULT_FRICTION) -> void:
	var new_velocity = _velocity.move_toward(Vector2.ZERO, friction)
	_velocity = move_and_slide(new_velocity)


func _update_animation_blend_position(blend_position: Vector2) -> void:
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.IDLE, blend_position)
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.MOVE, blend_position)
	_animation_tree.set(ANIMATION_BLEND_POSITION_PARAM % ANIMATION.ATTACK, blend_position)


func _attack_animation_finished() -> void:
	_state = State.IDLE
