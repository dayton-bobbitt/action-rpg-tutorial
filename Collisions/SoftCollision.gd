class_name SoftCollision
extends Area2D


signal soft_collision(_avoid_direction)
signal collision_avoided


func _on_SoftCollision_area_entered(area: SoftCollision):
	# direction away from collision
	var _avoid_direction = area.global_position.direction_to(global_position).normalized()
	
	set_deferred("monitorable", false)
	emit_signal("soft_collision", _avoid_direction)


func _on_SoftCollision_area_exited(area):
	set_deferred("monitorable", true)
	emit_signal("collision_avoided")
