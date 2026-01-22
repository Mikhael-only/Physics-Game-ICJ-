extends CharacterBody2D
class_name Player

var JUMP_FORCE: float = -300.0
var SPEED: float = 200.0
var is_being_pulled_by_orb: bool = false
var colected_flash: bool = false
var pode_mover: bool = true   # trava movimento durante diálogos

@export var acceleration: float = 400.0
@onready var foot: Node2D = $FootPosition
@onready var tilemap: TileMap = get_tree().get_first_node_in_group("level_tilemap")
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

func colect_skill_flash(be_flash: bool) -> void:
	colected_flash = be_flash
	if be_flash:
		SPEED += 1000.0 
		acceleration += 200

func set_in_gravity_orb(is_in_orb: bool) -> void:
	is_being_pulled_by_orb = is_in_orb
	if is_in_orb:
		velocity.y = 0.0 

func global_position_to_tile(pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(pos))
	
func get_friction_under_player() -> float:
	var tile_pos: Vector2i = global_position_to_tile(foot.global_position)

	if tile_pos not in tilemap.get_used_cells(0):
		return 0.4

	var source_id = tilemap.get_cell_source_id(0, tile_pos)
	var atlas_coord = tilemap.get_cell_atlas_coords(0, tile_pos)
	var alt = tilemap.get_cell_alternative_tile(0, tile_pos)

	var source = tilemap.tile_set.get_source(source_id)
	var tile_data = source.get_tile_data(atlas_coord, alt)
	if tile_data:
		var friction = tile_data.get_custom_data("friction")
		return friction if friction != null else 0.4

	return 0.4

func _physics_process(delta: float) -> void:
	
	var _friction = get_friction_under_player()
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	if pode_mover:
		if not is_being_pulled_by_orb:
			velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * _friction * delta)
			if direction != 0:
				animation.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_FORCE
	else:
		velocity.x = 0
		
	move_and_slide()
	apply_push_force()

	if pode_mover:
		if not is_on_floor():
			animation.play("jump")
		elif not is_being_pulled_by_orb and direction != 0:
			animation.play("run")
		else:
			animation.play("idle")
	else:
		animation.play("idle")

func apply_push_force() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Pushables:
			var direction = -collision.get_normal()
			direction.y = 0
			collider.slide_object(direction, SPEED)

func focar_npc(npc_pos: Vector2) -> void:
	var centro = global_position.lerp(npc_pos, 0.9)
	var tween = create_tween()
	tween.tween_property(camera, "global_position", centro, 0.5)
	tween.tween_property(camera, "zoom", Vector2(8, 8), 0.5)
	

func resetar_camera() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "global_position", global_position, 0.5)
	tween.tween_property(camera, "zoom", Vector2(4, 4), 0.5)
	
