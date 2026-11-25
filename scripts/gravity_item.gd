extends Area2D
class_name GravityItem

@export var float_amplitude: float = 5.0
@export var float_speed: float = 2.0
var _base_y: float

func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.001 * float_speed) * float_amplitude

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.collect_gravity_item()
		body.freeze_in_air(global_position, 0.1)
		queue_free()
