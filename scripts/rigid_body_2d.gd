extends RigidBody2D

@onready var dot_base = $Dot

var player = null
var sendo_carregada = false
var modo_mira = false
var lado = 1
var angulo = 0.0
var velocidade_lancamento = 500.0
var dots := []
var quantidade_pontos := 12
var intervalo := 0.04
var lado_travado = 1

func _ready():
	for i in range(quantidade_pontos):
		var d = dot_base.duplicate()
		d.visible = false
		add_child(d)
		dots.append(d)

func _process(delta):
	
	if not modo_mira:
		if Input.is_action_pressed("ui_left"):
			lado = -1
		elif Input.is_action_pressed("ui_right"):
			lado = 1
		
	if sendo_carregada and player:
		seguir_player()
		
		if modo_mira:
			controlar_angulo(delta)
			desenhar_trajetoria()
			
			if Input.is_action_just_pressed("ui_accept"):
				lancar()
			
			if Input.is_action_just_pressed("ui_interact"):
				sair_mira()
		
		else:
			if Input.is_action_just_pressed("ui_cancel"):
				soltar()

func desenhar_trajetoria():
	var pos_inicial = global_position
	
	var direcao = Vector2.RIGHT.rotated(deg_to_rad(angulo))
	direcao.x *= lado_travado
	
	var velocidade = direcao * velocidade_lancamento
	var gravidade = get_gravity()
	
	var space_state = get_world_2d().direct_space_state
	
	var pos_anterior = pos_inicial
	
	for i in range(quantidade_pontos):
		var t = (i + 1) * intervalo
		
		var pos = pos_inicial + (velocidade * t) + (0.5 * gravidade * t * t)
		
		var query = PhysicsRayQueryParameters2D.create(pos_anterior, pos)
		query.exclude = [self, player]
		
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

func seguir_player():
	global_position = player.global_position + Vector2(4 * lado, -6)
	
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("entrou")
		player = body

func _on_area_2d_body_exited(body):
	if body == player:
		player = null
		print("saiu")

func tentar_pegar():
	if player and Input.is_action_just_pressed("ui_accept"):
		print("tentou pegar")
		sendo_carregada = true
		freeze = true

func entrar_mira():
	modo_mira = true
	lado_travado = lado
	player.pode_mover = false
	player.camera.zoom = Vector2(3, 3)

func sair_mira():
	modo_mira = false
	player.pode_mover = true
	player.camera.zoom = Vector2(4, 4)
	
	esconder_trajetoria()

func controlar_angulo(delta):
	if Input.is_action_pressed("ui_up"):
		angulo -= 80 * delta
	if Input.is_action_pressed("ui_down"):
		angulo += 80 * delta
	
	angulo = clamp(angulo, -90, 90)

	if lado_travado == 1:
		rotation_degrees = angulo
	else:
		rotation_degrees = -angulo
	
	scale.x = lado_travado

	
func lancar():
	freeze = false
	
	var direcao = Vector2.RIGHT.rotated(deg_to_rad(angulo))
	direcao.x *= lado_travado
	
	
	apply_impulse(direcao * velocidade_lancamento)
	
	sendo_carregada = false
	sair_mira()
	player.pode_mover = false
	player.seguir_pedra(self)
	
func soltar():
	freeze = false
	global_position += Vector2(10, 0)
	sendo_carregada = false


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pegar_pedra(self)
