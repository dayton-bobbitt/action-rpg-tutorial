extends KinematicBody2D


export var max_speed: float = 75
export var acceleration: float = 10
export var friction: float = 10

var _velocity = Vector2.ZERO


func _physics_process(delta):
	var direction = _get_direction()
	
	_update_velocity(direction)
	move_and_slide(_velocity)


# Returns a normalized vector based on player input
func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	return direction.normalized()


func _update_velocity(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		# player is NOT moving; reduce velocity by friction until zero
		_velocity = _velocity.move_toward(Vector2.ZERO, friction)
	else:
		# player is moving; increase velocity by acceleration until max_speed
		_velocity = _velocity.move_toward(direction * max_speed, acceleration)
