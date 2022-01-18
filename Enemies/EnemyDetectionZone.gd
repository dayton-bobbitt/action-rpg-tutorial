extends Area2D


signal enemy_detected(enemy)
signal enemy_escaped(enemy)


func _enemy_detected(enemy) -> void:
	emit_signal("enemy_detected", enemy)


func _enemy_escaped(enemy) -> void:
	emit_signal("enemy_escaped", enemy)


func _on_area_entered(area):
	_enemy_detected(area)


func _on_area_exited(area):
	_enemy_escaped(area)


func _on_body_entered(body):
	_enemy_detected(body)


func _on_body_exited(body):
	_enemy_escaped(body)
