extends Area2D


@export var target_bridge: Node


@export var activation_sfx: AudioStreamPlayer2D


@export var activate_on_any_body: bool = false


var _triggered := false


signal plate_activated



func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if not target_bridge:
		push_warning("[PressurePlate '%s'] target_bridge não configurado!" % name)



func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return

	var is_player := body.is_in_group("pedra")
	if not activate_on_any_body and not is_player:
		return

	_trigger()



func _trigger() -> void:
	_triggered = true
	plate_activated.emit()


	if target_bridge and target_bridge.has_method("deploy"):
		target_bridge.deploy()

	_play_activation_effects()


func _play_activation_effects() -> void:

	activation_sfx.play()  
	var spr: Sprite2D = get_node_or_null("Sprite2D")
	if spr:
		spr.frame = 2 

	# Opção C — Modulate (pisca em amarelo)
	# var spr: Sprite2D = get_node_or_null("Sprite2D")
	# if spr:
	#     var tween := create_tween()
	#     tween.tween_property(spr, "modulate", Color.YELLOW, 0.1)
	#     tween.tween_property(spr, "modulate", Color.WHITE,  0.2)
	pass




func activate() -> void:
	if not _triggered:
		_trigger()


func is_activated() -> bool:
	return _triggered
