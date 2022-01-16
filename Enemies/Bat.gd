extends StaticBody2D


const ANIMATION = {
	FLYING = "flying",
	DEATH = "death"
}

onready var _animation_player = $AnimationPlayer


func _ready():
	_animation_player.play(ANIMATION.FLYING)


func _on_Hurtbox_area_entered(_area):
	_animation_player.play(ANIMATION.DEATH)


func _on_AnimationPlayer_animation_finished(anim_name: String):
	match anim_name:
		ANIMATION.DEATH:
			queue_free()
