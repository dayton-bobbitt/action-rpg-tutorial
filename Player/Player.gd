extends KinematicBody2D


const DEFAULT_FRICTION: int = 15
const ATTACK_FRICTION: int = 4

export var max_speed: float = 75
export var acceleration: float = 15
export var friction: float = DEFAULT_FRICTION

var _is_attacking = false
var _velocity = Vector2.ZERO

onready var _animation_tree = $AnimationTree
onready var _animation_tree_playback = _animation_tree.get("parameters/playback")


func _physics_process(_delta):
	var direction = _get_direction()
	
	_update_is_attacking()
	_update_velocity(direction)
	_update_animation(direction)
	
	_velocity = move_and_slide(_velocity)


# Returns a normalized vector based on player input
func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	return direction.normalized()


func _update_is_attacking() -> void:
	if not _is_attacking and Input.is_action_just_pressed("ui_attack"):
		_is_attacking = true
		friction = ATTACK_FRICTION


# Returns a boolean based on the direction of player input
func _is_moving(direction: Vector2) -> bool:
	return direction != Vector2.ZERO


func _update_velocity(direction: Vector2) -> void:
	if _is_attacking or not _is_moving(direction):
		# reduce velocity by friction until zero
		_velocity = _velocity.move_toward(Vector2.ZERO, friction)
	else:
		# increase velocity by acceleration until max_speed
		_velocity = _velocity.move_toward(direction * max_speed, acceleration)


func _update_animation(direction: Vector2) -> void:
	if _is_attacking:
		_animation_tree_playback.travel("Attack")
	elif _is_moving(direction):
		_animation_tree.set("parameters/Attack/blend_position", direction)
		_animation_tree.set("parameters/Idle/blend_position", direction)
		_animation_tree.set("parameters/Move/blend_position", direction)
		_animation_tree_playback.travel("Move")
	else:
		_animation_tree_playback.travel("Idle")


func _attack_animation_finished() -> void:
	_is_attacking = false
	friction = DEFAULT_FRICTION
