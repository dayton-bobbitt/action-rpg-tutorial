class_name Hurtbox
extends Area2D


signal destroyed


export var max_health: float

onready var _health = max_health


func _ready():
	assert(max_health > 0)


func _take_damage(hitbox: Hitbox) -> void:
	_health -= hitbox.attack_strength
	
	if _health <= 0:
		emit_signal("destroyed")


func _on_Hurtbox_area_entered(area):
	assert(area.name == "Hitbox")
	_take_damage(area)
