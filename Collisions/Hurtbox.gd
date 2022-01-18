class_name Hurtbox
extends Area2D


signal hit(knockback)
signal destroyed


export var max_health: float
export var HitEffect: PackedScene

onready var _health = max_health
onready var _collision_shape = $CollisionShape2D


func _ready():
	assert(max_health > 0)
	assert(_collision_shape.shape != null)


func _take_damage(hitbox: Hitbox) -> void:
	_health -= hitbox.attack_strength
	
	if _health > 0:
		var attack_direction = hitbox.get_parent().global_position.direction_to(global_position)
		var knockback = attack_direction * hitbox.knockback_strength
		
		_play_hit_effect()
		emit_signal("hit", knockback)
	else:
		emit_signal("destroyed")


func _play_hit_effect() -> void:
	if HitEffect != null:
		var hitEffect = HitEffect.instance()
		hitEffect.global_position = global_position
		get_tree().current_scene.add_child(hitEffect)


func _on_Hurtbox_area_entered(area):
	assert(area.name == "Hitbox")
	_take_damage(area)
