class_name Hurtbox
extends Area2D


signal hit(knockback)
signal destroyed


export var max_health: float

onready var _health = max_health


func _ready():
	assert(max_health > 0)


func _take_damage(hitbox: Hitbox) -> void:
	_health -= hitbox.attack_strength
	
	if _health > 0:
		var attack_direction = hitbox.get_parent().global_position.direction_to(global_position)
		var knockback = attack_direction * hitbox.knockback_strength
		
		emit_signal("hit", knockback)
	else:
		emit_signal("destroyed")


func _on_Hurtbox_area_entered(area):
	assert(area.name == "Hitbox")
	_take_damage(area)
