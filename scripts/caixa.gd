extends CharacterBody2D
class_name Pushables

@export var weight_modifier: float = 1.0
@export var acceleration: float = 400.0
@onready var foot = $FootPosition
@onready var tilemap = get_tree().get_first_node_in_group("level_tilemap")

var target_velocity_x: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	var _friction = get_friction_under_object()

	if target_velocity_x != 0:
		velocity.x = move_toward(velocity.x, target_velocity_x, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * _friction * delta)

	move_and_slide()
	target_velocity_x = 0.0

func slide_object(direction: Vector2, speed_of_player: float):
	target_velocity_x = direction.x * speed_of_player * weight_modifier

func get_friction_under_object() -> float:
	if not foot or not tilemap:
		return 0.4

	var tile_pos = tilemap.local_to_map(tilemap.to_local(foot.global_position))
	var source_id = tilemap.get_cell_source_id(0, tile_pos)
	if source_id == -1: return 0.4

	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
	if tile_data:
		var friction = tile_data.get_custom_data("friction")
		return friction if friction != null else 0.4

	return 0.4
