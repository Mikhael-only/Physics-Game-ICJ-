extends Area2D

var falas_por_estado = {
	0: ["Olá ser humano detes... digo, aventureiro!", "O que lhe traz a essa trilha?", "Conhecimento? Aventuras? Ou algo maior?", "Eu estava procurando um desbravador como voçê para algo.", "Estou fragmentado graças as Leis da Física quebradas em nosso mundo, e gostaria que voçê me ajudasse.", "Quero que voçê colete meus fragmentos e ajude a restauralos em meu sistema", "Sem mais enrolaçôes, vou falando com voçê pelo caminho"],
	1: ["Bom, vejo que voçê sabe andar, o mínimo.", "Durante a trajetória vai haver varios desafios obviamente.", "Ou então não haveria motivos para eu lhe ajudar.", "Nesse desafio haverá inércia, lei primordial da física.", "Se for muito rápido cairá por não conseguir parar, e se for muito lento não vencerá a inércia, e bom... perderá vida.","Agora siga em frente, porque quando um corpo está inércia, tende a ficar em inércia até uma força maior interferir."],
	2: ["Parabéns, primeiro desafio vencido, o mais fácil Ha Ha...", "Agora, está vendo esta caixa? voçê deve empurra-lá.", "Por ser pesada, é dificil empurrar no primeiro tempo.", "Mas conforme você aplica força vai vencendo a inèrcia e ganhando velocidade", "Sim da pra vencer a inércia, só não sei se vai dar para fazer com esses seus braços finos Ha Ha."],
	3: []
}

var indice: int = 0
var dialogo_ui
var player
var dialogo_ativo: bool = false
var dialogo_finalizado: bool = false
var ultimo_estado: int = -1
var tween: Tween
var ja_falou: bool = false

@export var deslocamento: float = 50
@export var duracao: float = 0.3

func _ready():
	dialogo_ui = get_node("/root/Mundo/Dialogue_UI")
	tween = create_tween()


func _process(delta: float) -> void:
	if dialogo_ativo and Input.is_action_just_pressed("interact"):
		if dialogo_ui.digitando:
			dialogo_ui.completar_fala()
		else:
			mostrar_dialogo()

func _on_body_entered(body: Node) -> void:
	if body is Player and not ja_falou:
		var estado = GameState.progresso_historia
		if estado != ultimo_estado:
			dialogo_finalizado = false
			indice = 0
			ultimo_estado = estado
		
		if not dialogo_ativo and not dialogo_finalizado:
			player = body
			iniciar_dialogo()


func iniciar_dialogo() -> void:
	subir()
	dialogo_ativo = true
	player.pode_mover = false
	await tween.finished
	player.focar_npc(global_position)
	mostrar_dialogo()


func mostrar_dialogo() -> void:
	var estado = GameState.progresso_historia
	var falas = falas_por_estado.get(estado, [])
	
	if indice >= falas.size():
		encerrar_dialogo()
	else:
		dialogo_ui.mostrar_fala(falas[indice], self)
		indice += 1

func encerrar_dialogo() -> void:
	GameState.avancar_historia()
	dialogo_ativo = false
	dialogo_finalizado = true
	player.resetar_camera()
	player.pode_mover = true
	dialogo_ui.ocultar()
	$CollisionShape2D.disabled = true
	ja_falou = true
	
func subir():
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:y", position.y - deslocamento, duracao)

func abaixar():
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:y", position.y + deslocamento, duracao)


func _on_area_animacao_body_entered(body: Node2D) -> void:
	if ja_falou and body is Player:
		subir()


func _on_area_animacao_body_exited(body: Node2D) -> void:
	if ja_falou and body is Player:
		abaixar()
