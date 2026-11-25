extends RigidBody2D

@onready var dot_base = $Dot
var player = null
var sendo_carregada = false
var modo_mira = false
var lado = 1
var angulo = 0.0
var velocidade_lancamento = 600.0
var dots := []
var quantidade_pontos := 12
var intervalo := 0.04
var lado_travado = 1
var _timer_parada: float = 0.0
var _timer_lancada: float = 0.0   
var _sumindo: bool = false
var _posicao_original: Vector2
var _rotacao_original: float
var _resetando := false

@export var abyss_y: float = 663.0
@export var tempo_ate_sumir: float = 3.0
@export var tempo_maximo_lancada: float = 8.0   
@export var distancia_maxima: float = 900.0     

const VELOCIDADE_LIMIAR: float = 2.0
const DISTANCIA_ORIGEM_LIMIAR: float = 10.0


func _ready():
	_posicao_original = global_position
	_rotacao_original = rotation
	for i in range(quantidade_pontos):
		var d = dot_base.duplicate()
		d.visible = false
		add_child(d)
		dots.append(d)

func _process(delta):
	
	if not _resetando and is_instance_valid(player) and player.is_dead:
		_resetar()
		return

	if not sendo_carregada and not _resetando and not _sumindo:

	
		if global_position.y > abyss_y:
			_resetar()
			return

		
		if global_position.distance_to(_posicao_original) > distancia_maxima:
			_sumir_e_resetar()
			return

		var na_origem = global_position.distance_to(_posicao_original) < DISTANCIA_ORIGEM_LIMIAR

		if na_origem:
			_timer_parada  = 0.0
			_timer_lancada = 0.0   

		else:
			var parada = linear_velocity.length() < VELOCIDADE_LIMIAR \
				and abs(angular_velocity) < 0.05

			if parada:
				
				_timer_lancada = 0.0
				_timer_parada += delta
				if _timer_parada >= tempo_ate_sumir:
					_timer_parada = 0.0
					_sumir_e_resetar()
			else:
				
				_timer_parada = 0.0
				_timer_lancada += delta
				if _timer_lancada >= tempo_maximo_lancada:
					_timer_lancada = 0.0
					_sumir_e_resetar()

	if not modo_mira:
		if Input.is_action_pressed("ui_left"):
			lado = -1
		elif Input.is_action_pressed("ui_right"):
			lado = 1

	if sendo_carregada and player:
		seguir_player()
		if is_instance_valid(player) and player.em_dialogo:
			return
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


func _resetar() -> void:
	if _resetando:
		return
	_resetando = true
	_sumindo      = false   
	_timer_parada  = 0.0
	_timer_lancada = 0.0  
	modulate.a    = 1.0

	if sendo_carregada and is_instance_valid(player):
		if modo_mira:
			modo_mira = false
			if not player.em_zona_camera:
				player.camera.zoom = Vector2(4, 4)
			esconder_trajetoria()
		player.pode_mover = true

	sendo_carregada = false
	modo_mira = false
	esconder_trajetoria()

	freeze = true
	linear_velocity  = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("global_position", _posicao_original)
	set_deferred("rotation", _rotacao_original)
	set_deferred("scale", Vector2.ONE)

	await get_tree().physics_frame
	await get_tree().physics_frame

	freeze = false
	_resetando = false

func morrer_por_area(area: Area2D) -> void:
	if area.is_in_group("death_zone"):
		_resetar()


func _sumir_e_resetar() -> void:
	if _sumindo:
		return
	_sumindo = true
	_timer_parada  = 0.0
	_timer_lancada = 0.0   

	var tw = create_tween()
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.8)
	await tw.finished

	freeze = true
	linear_velocity  = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("global_position", _posicao_original)
	set_deferred("rotation",        _rotacao_original)
	set_deferred("scale",           Vector2.ONE)

	await get_tree().physics_frame
	await get_tree().physics_frame

	freeze = false

	var tw2 = create_tween()
	tw2.set_trans(Tween.TRANS_SINE)
	tw2.set_ease(Tween.EASE_OUT)
	tw2.tween_property(self, "modulate:a", 1.0, 0.5)
	await tw2.finished

	_sumindo = false


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
		player = body

func _on_area_2d_body_exited(body):
	if body == player:
		player = null

func tentar_pegar():
	if player and Input.is_action_just_pressed("ui_accept"):
		_timer_parada  = 0.0
		_timer_lancada = 0.0   
		sendo_carregada = true
		freeze = true

func entrar_mira():
	modo_mira = true
	lado_travado = lado
	player.pode_mover = false
	if not player.em_zona_camera:
		player.camera.zoom = Vector2(3, 3)

func sair_mira():
	modo_mira = false
	player.pode_mover = true
	if not player.em_zona_camera:
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
	_timer_lancada = 0.0   
	var direcao = Vector2.RIGHT.rotated(deg_to_rad(angulo))
	direcao.x *= lado_travado
	apply_impulse(direcao * velocidade_lancamento)
	sendo_carregada = false
	sair_mira()
	player.pode_mover = false
	if not player.em_zona_camera:
		player.seguir_pedra(self)
	else:
		player.pode_mover = true

func soltar():
	freeze = false
	global_position += Vector2(10, 0)
	sendo_carregada = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.pegar_pedra(self)
