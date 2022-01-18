extends KinematicBody2D


enum State {
	IDLE,
	CHASE,
	ATTACK,
	DEAD
}

const ANIMATION = {
	FLYING = "flying",
	DEATH = "death"
}

const CHASE_MAX_SPEED: int = 40
const ATTACK_MAX_SPEED: int = 80
const CHASE_ACCELERATION: int = 15
const ATTACK_ACCELERATION: int = 25
const FRICTION: int = 12
const KNOCKBACK_RESISTANCE: int = 12
const ATTACK_DISTANCE: int = 25
const ATTACK_RECOIL: int = 150

var _state = State.IDLE
var _velocity = Vector2.ZERO
var _knockback_velocity = Vector2.ZERO
var _player: Player

onready var _sprite = $BatSprite
onready var _animation_player = $AnimationPlayer
onready var _attack_cooldown_timer = $AttackCooldownTimer


func _ready():
	_animation_player.play(ANIMATION.FLYING)


func _physics_process(_delta):
	if _state == State.DEAD:
		return
	
	if _has_knockback():
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_RESISTANCE)
		_knockback_velocity = move_and_slide(_knockback_velocity)
	else:
		_update_state()
		
		match _state:
			State.IDLE:
				_idle_state()
			State.CHASE:
				_chase_state()
			State.ATTACK:
				_attack_state()


func _has_knockback() -> bool:
	return _knockback_velocity != Vector2.ZERO


func _update_state() -> void:
	if not _attack_cooldown_timer.is_stopped():
		# bat just attacked and is temporarily idle
		_state = State.IDLE
	elif _is_attacking():
		_state = State.ATTACK
	elif _is_chasing():
		_state = State.CHASE
	else:
		_state = State.IDLE


func _is_chasing() -> bool:
	return _player != null


func _is_attacking() -> bool:
	if not _is_chasing() or not _attack_cooldown_timer.is_stopped():
		return false
	
	var distance_to_player = global_position.distance_to(_player.global_position)
	
	return distance_to_player < ATTACK_DISTANCE


func _idle_state() -> void:
	var new_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION)
	_velocity = move_and_slide(new_velocity)


func _chase_state() -> void:
	_move()


func _attack_state() -> void:
	_move(ATTACK_MAX_SPEED, ATTACK_ACCELERATION)


func _move(max_speed := CHASE_MAX_SPEED, acceleration := CHASE_ACCELERATION) -> void:
	var direction = global_position.direction_to(_player.global_position)
	var new_velocity = _velocity.move_toward(direction * max_speed, acceleration)
	
	_velocity = move_and_slide(new_velocity)
	_sprite.flip_h = _velocity.x < 0


func _on_AnimationPlayer_animation_finished(anim_name: String):
	match anim_name:
		ANIMATION.DEATH:
			queue_free()


func _on_Hurtbox_hit(knockback: Vector2):
	_knockback_velocity = knockback


func _on_Hurtbox_destroyed():
	_state = State.DEAD
	_animation_player.play(ANIMATION.DEATH)


func _on_enemy_detected(enemy: Player):
	_player = enemy


func _on_enemy_escaped(_enemy: Player):
	set_deferred("_player", null)


func _on_player_hit(area):
	var attack_knockback_direction = area.global_position.direction_to(global_position)
	_knockback_velocity = attack_knockback_direction * ATTACK_RECOIL
	
	_attack_cooldown_timer.start()
