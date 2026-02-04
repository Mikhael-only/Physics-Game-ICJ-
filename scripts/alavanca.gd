extends Area2D

@onready var ponte = get_node("../ponte")

func _on_body_entered(body):
	if body is RigidBody2D:
		ponte.descer()
		print('colisao')
		descer()
		
func descer():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", -40, 1.0)
