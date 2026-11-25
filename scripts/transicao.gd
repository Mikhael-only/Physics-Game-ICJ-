extends Node

@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var dialogue_ui = $Dialogue_UI

var trocando_de_fase := false

func _ready() -> void:
	color_rect.modulate.a = 0.0

func trocar_de_fase(caminho_da_cena: String, mensagem: String = "", duracao: float = 0.5) -> void:
	if trocando_de_fase:
		return
	trocando_de_fase = true

	
	var tween_out := create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(color_rect, "modulate:a", 1.0, duracao)
	_fade_musica(-80.0, duracao)
	await tween_out.finished

	
	if mensagem != "":
		dialogue_ui.mostrar_fala_transicao(mensagem)
		await dialogue_ui.dialogo_encerrado

	
	get_tree().change_scene_to_file(caminho_da_cena)
	await get_tree().process_frame

	
	var musicas_novas := get_tree().get_nodes_in_group("musica")
	var volumes_originais := {}
	for m in musicas_novas:
		volumes_originais[m] = m.volume_db
		m.volume_db = -80.0

	var tween_in := create_tween()
	tween_in.set_parallel(true)
	tween_in.tween_property(color_rect, "modulate:a", 0.0, duracao)
	for m in musicas_novas:
		tween_in.tween_property(m, "volume_db", volumes_originais[m], duracao)
	await tween_in.finished

	trocando_de_fase = false

func _fade_musica(volume_final: float, duracao: float) -> void:
	var musicas := get_tree().get_nodes_in_group("musica")
	if musicas.is_empty():
		return
	var tween := create_tween()
	tween.set_parallel(true)
	for m in musicas:
		tween.tween_property(m, "volume_db", volume_final, duracao)
