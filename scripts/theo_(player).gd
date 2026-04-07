extends CharacterBody2D
class_name Player

var JUMP_FORCE: float = -300.0
var SPEED: float = 200.0
var is_being_pulled_by_orb: bool = false
var colected_flash: bool = false
var pode_mover: bool = true
var is_dead: bool = false
var last_checkpoint: Vector2 = Vector2.ZERO 
var pushing := false
var frozen_in_air := false
var pedra_perto = null


@export var PUSH_SPEED_OBJECT: float = 1000.0
@export var PUSH_FORCE_RIGID: float = 3000.0
@export var acceleration: float = 400.0
@export var abyss_y: float = 663.0
@export var safe_position: Vector2 = Vector2.ZERO
@export var PUSH_VELOCITY_BOX: float = 120.0


@onready var foot: Node2D = $FootPosition
@onready var tilemap: TileMap = get_tree().get_first_node_in_group("level_tilemap")
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var raycast: RayCast2D = $RayCast2D
#@onready var effect1: AnimatedSprite2D = $Efects
#@onready var effect2: AnimatedSprite2D = $Efects2

func freeze_in_air(target_pos: Vector2, time: float) -> void:
	frozen_in_air = true
	pode_mover = false
	velocity = Vector2.ZERO
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.4)
	await tween.finished
	
	await get_tree().create_timer(time).timeout
	
	animation.play("unstable")
	#effect1.play("efect_colect")
	#effect2.play("efect_colect")

	animation.speed_scale = 0.2
	#effect1.speed_scale = 0.2
	#effect2.speed_scale = 0.2
	
	var original_pos = global_position
	var duration := 7.0
	var step := 0.016
	var elapsed := 0.0
	
	while elapsed < duration:
		var progress = elapsed / duration
		
		var strength = pow(progress, 3) * 25
		
		global_position = original_pos + Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		
		var speed = lerp(0.2, 3.0, progress)

		animation.speed_scale = speed
		#effect1.speed_scale = speed
		#effect2.speed_scale = speed
		
		await get_tree().create_timer(step).timeout
		elapsed += step
	
	var end_tween = create_tween()
	end_tween.set_trans(Tween.TRANS_SINE)
	end_tween.set_ease(Tween.EASE_IN_OUT)
	end_tween.tween_property(self, "global_position", original_pos, 0.25)
	await end_tween.finished
	
	animation.speed_scale = 1.0
	#effect1.speed_scale = 1.0
	#effect2.speed_scale = 1.0

	#effect1.stop()
	#effect2.stop()
	animation.play("idle")
	
	frozen_in_air = false
	pode_mover = true

func colect_skill_flash(be_flash: bool) -> void:
	colected_flash = be_flash
	if be_flash:
		SPEED += 10000.0 
		acceleration += 10

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
	
func _process(delta):
	if pedra_perto:
		pedra_perto.tentar_pegar()
	
	if pedra_perto and pedra_perto.sendo_carregada:
		if Input.is_action_just_pressed("interact"):
			if pedra_perto.modo_mira:
				pedra_perto.sair_mira()
			else:
				pedra_perto.entrar_mira()
		

func _physics_process(delta: float) -> void:
	#print(velocity.x)
	if is_dead:
		return
	
	var _friction = get_friction_under_player()
	var direction = Input.get_axis("ui_left", "ui_right")
	raycast.target_position.x = direction * 15
	
	if not is_on_floor() and not frozen_in_air:
		velocity.y += get_gravity().y * delta
		
	if pode_mover:
		if not is_being_pulled_by_orb:
			velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * _friction * delta)
			if direction != 0:
				animation.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = JUMP_FORCE
	else:
		velocity.x = 0
		

	move_and_slide()
	apply_push_force(direction, delta)
	if pushing:
		velocity.x = direction * PUSH_VELOCITY_BOX


	if frozen_in_air:
		return
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
	
	pushing = false

	if move_direction == 0:
		return

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if normal.x * move_direction < -0.5:
			
			if collider is RigidBody2D:
				collider.apply_central_force(Vector2(-normal.x * PUSH_FORCE_RIGID, 0))


			elif is_on_floor() and collider is Pushables:
				pushing = true
				collider.push(sign(move_direction), PUSH_SPEED_OBJECT, delta)
				velocity.x = collider.velocity.x
				
func focar_npc(npc_pos: Vector2) -> void:
	
	var pos_global_atual = camera.global_position
	
	camera.top_level = true
	camera.global_position = pos_global_atual
	
	var tween = create_tween()
	tween.tween_property(camera, "global_position", npc_pos, 0.5)
	tween.tween_property(camera, "zoom", Vector2(8, 8), 0.5)
	
func resetar_camera() -> void:
	pode_mover = false
	
	var alvo = global_position
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(camera, "global_position", alvo, 0.5)
	tween.tween_property(camera, "zoom", Vector2(4, 4), 0.5)
	
	await tween.finished
	
	var pos_global_atual = camera.global_position
	
	camera.top_level = false
	camera.position = camera.get_parent().to_local(pos_global_atual)
	
	pode_mover = true
	
	
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
	
func _on_area_2d_body_entered(body):
	if body.is_in_group("pedra"):
		pedra_perto = body

func _on_area_2d_body_exited(body):
	if body == pedra_perto:
		pedra_perto = null

func seguir_pedra(pedra):
	camera.top_level = true
	
	var suavidade := 0.1
	var tempo_max := 4.0
	var tempo := 0.0
	
	while pedra and tempo < tempo_max:
		camera.global_position = pedra.global_position.lerp(
			pedra.global_position,
			suavidade
		)
		
		camera.zoom = camera.zoom.lerp(Vector2(3, 3), 0.05)
		
		await get_tree().process_frame
		tempo += get_process_delta_time()
	
	resetar_camera()
