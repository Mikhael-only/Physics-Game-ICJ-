extends Area2D


@export var marcador: Marker2D

@export var zoom_alvo: Vector2 = Vector2(2, 2)

@export var duracao: float = 0.8

var _player: Player = null
var _camera: Camera2D = null
var _zoom_original: Vector2
var _posicao_local_original: Vector2 
var _tween: Tween

func _on_body_entered(body: Node2D) -> void:
	if body is Player and _player == null:
		_player = body
		_player.em_zona_camera = true 
		_camera = body.camera
		_zoom_original = _camera.zoom
		_posicao_local_original = _camera.position  
		_travar_camera()

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player.em_zona_camera = false 
		_soltar_camera()

func _travar_camera() -> void:
	if _tween:
		_tween.kill()

	var alvo := marcador.global_position if marcador else global_position


	var pos_atual := _camera.global_position
	_camera.top_level = true
	_camera.global_position = pos_atual   

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_parallel(true)
	_tween.tween_property(_camera, "global_position", alvo, duracao)
	_tween.tween_property(_camera, "zoom", zoom_alvo, duracao)

func _soltar_camera() -> void:
	if not is_instance_valid(_player) or not is_instance_valid(_camera):
		_player = null
		_camera = null
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_parallel(true)
	_tween.tween_property(_camera, "global_position", _player.global_position, duracao)
	_tween.tween_property(_camera, "zoom", _zoom_original, duracao)

	await _tween.finished

	
	if is_instance_valid(_camera) and is_instance_valid(_player):
		_camera.top_level = false
		_camera.position = _posicao_local_original 
	_player = null
	_camera = null
