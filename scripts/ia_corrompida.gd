extends Area2D

@export var falas: Array[String] = []

var indice: int = 0
var dialogo_ui
var dialogo_ativo: bool = false
var dialogo_finalizado: bool = false
var tween: Tween
var ja_falou: bool = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var olho_esquerdo = $OlhoEsquerdo
@onready var olho_direito = $OlhoDireito
@onready var boca = $Boca
@onready var pupila_esquerda: Sprite2D = $OlhoEsquerdo/Sprite2D
@onready var pupila_direita: Sprite2D = $OlhoDireito/Sprite2D
@onready var som_falando: AudioStreamPlayer2D = $SomFalando

@export var raio_orbita: float = 1.5
@export var suavidade: float = 0.15
@export var deslocamento: float = 50
@export var duracao: float = 0.3

func _ready():
	dialogo_ui = get_tree().get_first_node_in_group("dialogue_ui")
	tween = create_tween()
	olho_esquerdo.modulate.a = 0
	olho_direito.modulate.a = 0
	boca.modulate.a = 0


var estava_digitando: bool = false

func _process(delta: float) -> void:
	if dialogo_ativo:
		if dialogo_ui.digitando:
			boca.play("falando")
			if not estava_digitando:
				som_falando.play()
				estava_digitando = true
		else:
			boca.play("idle")
			if estava_digitando:
				som_falando.stop()
				estava_digitando = false
	
	atualizar_pupila(pupila_esquerda, olho_esquerdo)
	atualizar_pupila(pupila_direita, olho_direito)
	if dialogo_ativo and Input.is_action_just_pressed("interact"):
		if dialogo_ui.digitando:
			dialogo_ui.completar_fala()
		else:
			mostrar_dialogo()


func _on_body_entered(body: Node) -> void:
	if body is Player and not ja_falou:
		if not dialogo_ativo and not dialogo_finalizado:
			player = body
			iniciar_dialogo()


func iniciar_dialogo() -> void:
	aparecer()
	dialogo_ativo = true
	player.pode_mover = false
	player.em_dialogo = true        
	await animation.animation_finished
	player.focar_npc(global_position)
	mostrar_dialogo()


func mostrar_dialogo() -> void:
	if indice >= falas.size():
		encerrar_dialogo()
	else:
		dialogo_ui.mostrar_fala(falas[indice], self)
		indice += 1


func encerrar_dialogo() -> void:
	GameState.avancar_historia()
	dialogo_ativo = false
	dialogo_finalizado = true
	player.em_dialogo = false       
	player.resetar_camera()
	dialogo_ui.ocultar()
	$CollisionShape2D.disabled = true
	ja_falou = true

func aparecer():
	animation.play("entrada")
	var tween = create_tween()
	tween.tween_property(boca, "modulate:a", 1.0, 0.1)
	tween.tween_property(olho_esquerdo, "modulate:a", 1.0, 0.4)
	tween.tween_property(olho_direito, "modulate:a", 1.0, 0.4)
	await animation.animation_finished
	animation.play("idle")


func sair():
	animation.play("saida")
	var tween = create_tween()
	tween.tween_property(boca, "modulate:a", 0.0, 0.1)
	tween.tween_property(olho_esquerdo, "modulate:a", 0.0, 0.2)
	tween.tween_property(olho_direito, "modulate:a", 0.0, 0.2)


func _on_area_animacao_body_entered(body: Node2D) -> void:
	if ja_falou and body is Player:
		aparecer()


func _on_area_animacao_body_exited(body: Node2D) -> void:
	if ja_falou and body is Player:
		sair()


func atualizar_pupila(pupila: Sprite2D, olho: Node2D):
	var direcao = (player.global_position - olho.global_position).normalized()
	var alvo = direcao * raio_orbita
	pupila.position = pupila.position.lerp(alvo, suavidade)
