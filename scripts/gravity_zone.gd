extends Area2D
class_name GravityZone

@export var forced_gravity: float = 3.0  

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.entrar_zona_gravidade(forced_gravity)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.sair_zona_gravidade()
