extends Area2D

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.die()
	elif body is RigidBody2D and body.has_method("_resetar"):
		body._resetar()
