extends Area2D

var falas_por_estado = {
	0: ["Olá ser humano detes... digo, aventureiro!", "O que lhe traz a essa trilha?", "Conhecimento? Aventuras? Ou algo maior?", "Eu estava procurando um desbravador como voçê para algo.", "Estou fragmentado graças as Leis da Física quebradas em nosso mundo, e gostaria que voçê me ajudasse.", "Quero que voçê colete meus fragmentos e ajude a restauralos em meu sistema", "Sem mais enrolaçôes, vou falando com voçê pelo caminho"],
	1: ["Bom, vejo que voçê sabe andar, o mínimo.", "Durante a trajetória vai haver varios desafios obviamente.", "Ou então não haveria motivos para eu lhe ajudar.", "Nesse desafio haverá inércia, lei primordial da física.", "Se for muito rápido cairá por não conseguir parar, e se for muito lento não vencerá a inércia, e bom... perderá vida.","Agora siga em frente, porque quando um corpo está inércia, tende a ficar em inércia até uma força maior interferir."],
	2: ["Parabéns, primeiro desafio vencido, o mais fácil Ha Ha...", "Agora, está vendo esta caixa? voçê deve empurra-lá.", "Por ser pesada, é dificil empurrar no primeiro tempo.", "Mas conforme você aplica força vai vencendo a inèrcia e ganhando velocidade", "Sim da pra vencer a inércia, só não sei se vai dar para fazer com esses seus braços finos Ha Ha."],
	3: ["Bom, Bom.", "Vejo que você não é qualquer um.", "Então não é mais criança para eu estar te dando parabéns toda vez.", "Agora, está vendo aquela bola?", "Voçê deve empurrá-la para ativar e abaixar a ponte.", "Tente pegar um pouco de impulso com ela em vez de ir direto.", "Esferas não sofrem tanto de atrito com o solo quanto caixas.", "Então deve ser mais fácil.", "Se é que existe algo fácil para voçê..."],
	4: ["Está vendo que mudou de terreno?", "Agora em vez de grama voçê está andando em lama.", "Está sentindo o chão mais escorregadio?", "A lama é escorregadia pois seu atrito é menor, voçê tem menos tração sobre ela.", "Demora mais para acelerar e freiar.", "Cuidado, será mais difícil para pular e manipular caixas.", "Logo a frente haverá duas caixas.", "Minha dica é: encaixe a menor para depois passar o maior.", "E aí voçê pula.", "Ou entâo sofra com a ignorância Ha Ha."],
	5: ["Foi muito difícil?", "Realmente, acho que não há nada fácil para você nerd de laboratório.", "Mas persevere, logo a frente haverá algo benéfico para nós dois."],
	6: ["Está vendo pequeno garfanhoto?", "Um de meus fragmentos está bem bem a sua frente.", "Colete-o e me dê.", "Eu faria eu mesmo se não estivesse fragmentado.", "Vá, AGORA!"],
	7: ["Que interessante, e frustrante.", "Pareçe que meu fragmento se uniu a voçê.", "O fragmento da inércia eu acredito.", "Vamos, teste seus limites.", "Aparentemente eu não terei meus fragmentos tão cedo."],
	8: ["Eu criei um radar de velocidade logo a frente.", "Se voçê quiser saber o quão rápido é, pode usá-lo.", "Vamos em frente!"],
	9: ["Pronto, eu ativei um portal improvisado para voçê.", "Quando estiver pronto é só pular para dentro dele para próxima aventura.", "Voçê ainda tem muito o que fazer.", "A inércia foi só um dos conceitos que terá que aprender.", "Boa sorte, e te vejo do outro lado!"]
	}

var indice: int = 0
var dialogo_ui
var dialogo_ativo: bool = false
var dialogo_finalizado: bool = false
var ultimo_estado: int = -1
var tween: Tween
var ja_falou: bool = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var olho_esquerdo = $OlhoEsquerdo
@onready var olho_direito = $OlhoDireito
@onready var boca = $Boca
@onready var pupila_esquerda: Sprite2D = $OlhoEsquerdo/Sprite2D
@onready var pupila_direita: Sprite2D = $OlhoDireito/Sprite2D

@export var raio_orbita: float = 1.5
@export var suavidade: float = 0.15
@export var deslocamento: float = 50
@export var duracao: float = 0.3

func _ready():
	dialogo_ui = get_node("/root/Mundo/Dialogue_UI")
	tween = create_tween()
	olho_esquerdo.modulate.a = 0
	olho_direito.modulate.a = 0
	boca.modulate.a = 0


func _process(delta: float) -> void:
	
	if dialogo_ativo:
		if dialogo_ui.digitando:
			boca.play("falando")
		else:
			boca.play("idle")
		
	atualizar_pupila(pupila_esquerda, olho_esquerdo)
	atualizar_pupila(pupila_direita, olho_direito)
	
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
	aparecer()
	dialogo_ativo = true
	player.pode_mover = false
	await animation.animation_finished
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
