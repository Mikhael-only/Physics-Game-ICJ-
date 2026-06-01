extends Node2D

@onready var ponto_saida = $PontoSaida
@onready var dot_base = $Dot

var pedra = null
var player = null

var modo_mira = false
var angulo = -45.0
var velocidade_lancamento = 700.0

var dots := []
var quantidade_pontos := 12
var intervalo := 0.04

func _ready():
	for i in range(quantidade_pontos):
		var d = dot_base.duplicate()
		d.visible = false
		add_child(d)
		dots.append(d)

func _process(delta):
	if pedra:
		pedra.global_position = ponto_saida.global_position
		
		if modo_mira:
			controlar_angulo(delta)
			desenhar_trajetoria()
			
			if Input.is_action_just_pressed("ui_accept"):
				lancar()
			
			if Input.is_action_just_pressed("ui_interact"):
				sair_mira()

# 🔗 Conecta pedra na máquina
func conectar_pedra(p):
	pedra = p
	pedra.freeze = true

# 🔗 Conecta player
func conectar_player(p):
	player = p

# 🎯 Entrar na mira (AGORA COM CONDIÇÃO)
func entrar_mira():
	if not player or not player.tem_pedra:
		print("Você precisa de uma pedra!")
		return
	
	conectar_pedra(player.pedra_atual)
	player.tem_pedra = false
	player.pedra_atual = null
	
	modo_mira = true
	player.pode_mover = false
	player.camera.zoom = Vector2(3, 3)

# ❌ Sair da mira (devolve pedra)
func sair_mira():
	modo_mira = false
	
	if pedra:
		player.tem_pedra = true
		player.pedra_atual = pedra
		pedra = null
	
	player.pode_mover = true
	player.camera.zoom = Vector2(4, 4)
	
	esconder_trajetoria()

# 🎮 Controle do ângulo (fixo)
func controlar_angulo(delta):
	if Input.is_action_pressed("ui_up"):
		angulo -= 80 * delta
	if Input.is_action_pressed("ui_down"):
		angulo += 80 * delta
	
	# 🔒 limite de ângulo
	angulo = clamp(angulo, -80, -10)

	rotation_degrees = angulo

# 🚀 Lançar pedra
func lancar():
	pedra.freeze = false
	
	var direcao = Vector2.RIGHT.rotated(deg_to_rad(angulo))
	pedra.apply_impulse(direcao * velocidade_lancamento)
	
	pedra = null
	
	sair_mira()

# 📈 Trajetória
func desenhar_trajetoria():
	var pos_inicial = ponto_saida.global_position
	
	var direcao = Vector2.RIGHT.rotated(deg_to_rad(angulo))
	var velocidade = direcao * velocidade_lancamento
	var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity") * Vector2.DOWN
	
	var space_state = get_world_2d().direct_space_state
	var pos_anterior = pos_inicial
	
	for i in range(quantidade_pontos):
		var t = (i + 1) * intervalo
		
		var pos = pos_inicial + (velocidade * t) + (0.5 * gravidade * t * t)
		
		var query = PhysicsRayQueryParameters2D.create(pos_anterior, pos)
		var resultado = space_state.intersect_ray(query)
		
		var dot = dots[i]
		
		if resultado:
			dot.visible = true
			dot.global_position = resultado.position
			
			for j in range(i + 1, quantidade_pontos):
				dots[j].visible = false
			break
		else:
			dot.visible = true
			dot.global_position = pos
			
			var escala = lerp(0.1, 0.08, float(i) / quantidade_pontos)
			dot.scale = Vector2(escala, escala)
			
			var alpha = lerp(0.9, 0.1, float(i) / quantidade_pontos)
			var cor = dot.modulate
			cor.a = alpha
			dot.modulate = cor
		
		pos_anterior = pos

func esconder_trajetoria():
	for d in dots:
		d.visible = false
