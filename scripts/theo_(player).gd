extends CharacterBody2D
class_name Player

var JUMP_FORCE: float = -300.0
var SPEED: float = 200.0
var is_being_pulled_by_orb: bool = false
var colected_flash: bool = false
var pode_mover: bool = true
var is_dead: bool = false
var last_checkpoint: Vector2 = Vector2.ZERO 

@export var PUSH_SPEED_OBJECT: float = 100.0
@export var PUSH_FORCE_RIGID: float = 3000.0
@export var acceleration: float = 400.0
@export var abyss_y: float = 663.0
@export var safe_position: Vector2 = Vector2.ZERO
@export var PUSH_VELOCITY_BOX: float = 150.0

@onready var foot: Node2D = $FootPosition
@onready var tilemap: TileMap = get_tree().get_first_node_in_group("level_tilemap")
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var raycast: RayCast2D = $RayCast2D

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
	if is_dead:
		return
	
	var _friction = get_friction_under_player()
	var direction = Input.get_axis("ui_left", "ui_right")
	raycast.target_position.x = direction * 15
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	if pode_mover:
		if not is_being_pulled_by_orb:
			velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * _friction * delta)
			if direction != 0:
				animation.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_FORCE
	else:
		velocity.x = 0
		
	move_and_slide()
	apply_push_force(direction, delta)


	if pode_mover:
		if not is_on_floor():
			animation.play("jump")
		elif not is_being_pulled_by_orb and direction != 0:
			animation.play("run")
		else:
			animation.play("idle")
	else:
		animation.play("idle")


	if global_position.y > abyss_y:
		die()

func apply_push_force(move_direction: float, delta: float) -> void:

	if move_direction == 0:
		return

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if normal.x * move_direction < -0.5:
			
			if collider is RigidBody2D:
				collider.apply_central_force(Vector2(-normal.x * PUSH_FORCE_RIGID, 0))


			elif collider is Pushables:

				collider.push(move_direction * PUSH_VELOCITY_BOX)
				
func focar_npc(npc_pos: Vector2) -> void:
	
	# Guarda posição global atual
	var pos_global_atual = camera.global_position
	
	camera.top_level = true
	camera.global_position = pos_global_atual
	
	var tween = create_tween()
	tween.tween_property(camera, "global_position", npc_pos, 0.5)
	tween.tween_property(camera, "zoom", Vector2(8, 8), 0.5)
	
func resetar_camera() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(4, 4), 0.5)
	await tween.finished

	var pos_global_atual = camera.global_position

	camera.top_level = false

	camera.position = camera.get_parent().to_local(pos_global_atual)
	
	
func set_checkpoint(pos: Vector2) -> void:
	last_checkpoint = pos
	

func die() -> void:
	is_dead = true
	pode_mover = false
	velocity = Vector2.ZERO
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
	pode_mover = true
	
