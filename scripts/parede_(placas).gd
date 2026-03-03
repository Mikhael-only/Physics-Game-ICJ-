extends Node2D

@export var texto_da_placa: String = "Texto padrão"

@onready var placa: Sprite2D = $Sprite2D
@onready var texto: Label = $Label
@onready var area: Area2D = $Area2D
@export var posicao_tecla: Vector2:
	set(value):
		posicao_tecla = value
		if has_node("Icone"):
			$Icone.position = value
@export var textura_tecla: Texture2D:
	set(value):
		textura_tecla = value
		if has_node("Icone"):
			$Icone.texture = value
@export var escala_tecla: Vector2 = Vector2(1, 1):
	set(value):
		escala_tecla = value
		if has_node("Icone"):
			$Icone.scale = value
			
var posicao_base: Vector2
var tween: Tween
			
func _ready():
	if has_node("Icone"):
		$Icone.scale = escala_tecla
		$Icone.position = posicao_tecla
		$Icone.texture = textura_tecla

	texto.text = texto_da_placa
	posicao_base = position
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if tween:
			tween.kill()

		tween = create_tween()
		tween.tween_property(self, "position", posicao_base + Vector2(0, -100), 0.6)

func _on_body_exited(body):
	if body.is_in_group("player"):
		if tween:
			tween.kill()

		tween = create_tween()
		tween.tween_property(self, "position", posicao_base, 0.6)
