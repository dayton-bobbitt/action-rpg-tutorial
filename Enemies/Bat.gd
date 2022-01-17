extends KinematicBody2D


const ANIMATION = {
	FLYING = "flying",
	DEATH = "death"
}

const KNOCKBACK_RESISTANCE: int = 12

var _knockback_velocity = Vector2.ZERO

onready var _animation_player = $AnimationPlayer


func _ready():
	_animation_player.play(ANIMATION.FLYING)


func _physics_process(_delta):
	if _has_knockback():
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_RESISTANCE)
		_knockback_velocity = move_and_slide(_knockback_velocity)


func _has_knockback() -> bool:
	return _knockback_velocity != Vector2.ZERO


func _on_AnimationPlayer_animation_finished(anim_name: String):
	match anim_name:
		ANIMATION.DEATH:
			queue_free()


func _on_Hurtbox_hit(knockback: Vector2):
	_knockback_velocity = knockback


func _on_Hurtbox_destroyed():
	_animation_player.play(ANIMATION.DEATH)
