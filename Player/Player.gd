extends KinematicBody2D


export var max_speed: float = 75
export var acceleration: float = 15
export var friction: float = 15

var _velocity = Vector2.ZERO

onready var _animation_tree = $AnimationTree
onready var _animation_tree_playback = _animation_tree.get("parameters/playback")


func _physics_process(delta):
	var direction = _get_direction()
	
	_update_velocity(direction)
	_update_animation(direction)
	
	_velocity = move_and_slide(_velocity)


# Returns a normalized vector based on player input
func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	return direction.normalized()


# Returns a boolean based on the direction of player input
func _is_moving(direction: Vector2) -> bool:
	return direction != Vector2.ZERO


func _update_velocity(direction: Vector2) -> void:
	if _is_moving(direction):
		# increase velocity by acceleration until max_speed
		_velocity = _velocity.move_toward(direction * max_speed, acceleration)
	else:
		# reduce velocity by friction until zero
		_velocity = _velocity.move_toward(Vector2.ZERO, friction)


func _update_animation(direction: Vector2) -> void:
	if _is_moving(direction):
		_animation_tree.set("parameters/Idle/blend_position", direction)
		_animation_tree.set("parameters/Move/blend_position", direction)
		_animation_tree_playback.travel("Move")
	else:
		_animation_tree_playback.travel("Idle")


