extends Area2D

@export_file("*.tscn") var cena_destino: String
@export_multiline var mensagem_transicao: String = ""
@export var duracao_fade: float = 5.0

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if Transicao.trocando_de_fase:
		return
	_parar_player(body)
	Transicao.trocar_de_fase(cena_destino, mensagem_transicao, duracao_fade)

func _parar_player(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO
	body.set_physics_process(false)
	body.set_process_input(false)
