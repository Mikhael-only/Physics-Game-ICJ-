extends CharacterBody2D
class_name Pushables

@export var gravity_scale: float = 1.0
@export var friction_ground: float = 8.0
@export var push_inertia: float = 4.0
@export var abyss_y: float = 665.0
@export var safe_position: Vector2 = Vector2.ZERO

@onready var tilemap = get_tree().get_first_node_in_group("level_tilemap")
@onready var foot = $FootPosition
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var last_checkpoint: Vector2 = Vector2.ZERO
var push_velocity_target: float = 0.0
var is_being_pushed: bool = false
var is_dead: bool = false
var pode_mover: bool = true

func _ready() -> void:
	safe_position = global_position

func _physics_process(delta: float) -> void:
	
	if is_dead:
		velocity = Vector2.ZERO
		return
		
	if global_position.y > abyss_y:
		die()
		
	if not is_on_floor():
		velocity.y += get_gravity().y * gravity_scale * delta

	if is_being_pushed:
		velocity.x = move_toward(velocity.x, push_velocity_target, push_inertia * 100 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction_ground * 100 * delta)

	move_and_slide()
	is_being_pushed = false
	push_velocity_target = 0.0

func push(target_speed: float) -> void:
	is_being_pushed = true
	push_velocity_target = target_speed
	
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
	
func die() -> void:
	is_dead = true
	animation.play("death")
	await animation.animation_finished
	respawn()
	
func respawn() -> void:
	if last_checkpoint != Vector2.ZERO:
		global_position = last_checkpoint
	else:
		global_position = safe_position
	animation.play("respawn")
	await animation.animation_finished
	is_dead = false
