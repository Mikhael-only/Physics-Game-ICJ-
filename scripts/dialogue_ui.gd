extends CanvasLayer

@onready var painel = $Panel
@onready var texto = $Panel/Label
var fala_completa: String = ""
var indice_letra: int = 0
var timer: Timer
var npc_ref
var digitando: bool = false

func _ready():
	painel.visible = false
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.05
	timer.connect("timeout", Callable(self, "_mostrar_proxima_letra"))

func mostrar_fala(fala: String, npc):
	painel.visible = true
	fala_completa = fala
	texto.text = ""
	indice_letra = 0
	npc_ref = npc
	digitando = true
	timer.start()

func _mostrar_proxima_letra():
	if indice_letra < fala_completa.length():
		texto.text += fala_completa[indice_letra]
		indice_letra += 1
	else:
		timer.stop()
		digitando = false

func completar_fala():
	# ✅ completa imediatamente o texto
	texto.text = fala_completa
	timer.stop()
	digitando = false

func ocultar():
	painel.visible = false
