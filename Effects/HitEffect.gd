extends AnimatedSprite


func _ready():
	play()


func _on_animation_finished():
	self.queue_free()
