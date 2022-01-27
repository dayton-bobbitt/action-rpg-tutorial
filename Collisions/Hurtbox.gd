class_name Hurtbox
extends Area2D


signal hit(knockback)
signal invincibility_started
signal invincibility_ended
signal destroyed


export var max_health: float
export var HitEffect: PackedScene
export var invincibility_secs_on_hit: float = 0

onready var _health = max_health
onready var _collision_shape = $CollisionShape2D
onready var _invincibility_timer = $InvincibilityTimer


func _ready():
	assert(max_health > 0)
	assert(_collision_shape.shape != null)
	_invincibility_timer.wait_time = invincibility_secs_on_hit


func _take_damage(hitbox: Hitbox) -> void:
	_health -= hitbox.attack_strength
	
	if _health > 0:
		var attack_direction = hitbox.get_parent().global_position.direction_to(global_position)
		var knockback = attack_direction * hitbox.knockback_strength
		
		_play_hit_effect()
		_make_invincible()
		emit_signal("hit", knockback)
	else:
		emit_signal("destroyed")


func _has_iframes() -> bool:
	return invincibility_secs_on_hit > 0


func _make_invincible() -> void:
	if _has_iframes():
		_invincibility_timer.start()
		set_deferred("monitoring", false)
		emit_signal("invincibility_started")


func _make_vulnerable() -> void:
	set_deferred("monitoring", true)
	emit_signal("invincibility_ended")


func _play_hit_effect() -> void:
	if HitEffect != null:
		var hitEffect = HitEffect.instance()
		hitEffect.global_position = global_position
		get_tree().current_scene.add_child(hitEffect)


func _on_Hurtbox_area_entered(area):
	assert(area.name == "Hitbox")
	_take_damage(area)


func _on_InvincibilityTimer_timeout():
	_make_vulnerable()
