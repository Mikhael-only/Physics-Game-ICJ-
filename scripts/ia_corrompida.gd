extends Area2D

var falas = ["Olá aventureiro!",
	"Cuidado com os monstros na floresta.",
	"Boa sorte na sua jornada!"]

var indice: int = 0
var dialogo_ui
var player
var dialogo_ativo: bool = false
var dialogo_finalizado: bool = false
var interacoes_processadas: int = 0

func _ready():
	dialogo_ui = get_node("/root/Mundo/Dialogue_UI")

func _process(delta: float) -> void:
	
	if dialogo_ativo and Input.is_action_just_pressed("ui_accept"):
		if dialogo_ui.digitando:
			dialogo_ui.completar_fala()
		else:
			mostrar_dialogo()
			
func _on_body_entered(body: Node) -> void:
	if body is Player and not dialogo_ativo and not dialogo_finalizado:
		player = body
		iniciar_dialogo()

func iniciar_dialogo() -> void:
	dialogo_ativo = true
	player.pode_mover = false
	player.focar_npc(global_position)
	mostrar_dialogo()

func mostrar_dialogo() -> void:	
	if indice >= falas.size():
		encerrar_dialogo()
	else:
		dialogo_ui.mostrar_fala(falas[indice], self)
		indice += 1


func encerrar_dialogo() -> void:
	dialogo_ativo = false
	dialogo_finalizado = true
	player.resetar_camera()
	player.pode_mover = true
	dialogo_ui.ocultar()
