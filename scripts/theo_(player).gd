extends CharacterBody2D
class_name Player

var JUMP_FORCE = -300.0
var SPEED = 200.0
var is_being_pulled_by_orb = false
var colected_flash = false

@export var acceleration = 400.00
@onready var foot = $FootPosition
@onready var tilemap = get_tree().get_first_node_in_group("level_tilemap")
@onready var animation := $AnimatedSprite2D

# Super velocidade ao coletar o buff
func colect_skill_flash(be_flash: bool):
	colected_flash = be_flash
	if be_flash:
		SPEED += 1000.0 
		acceleration += 200
	
	
# Anula a gravidade global quando interage com um orbe de gravidade
func set_in_gravity_orb(is_in_orb: bool):
		is_being_pulled_by_orb = is_in_orb
		if is_in_orb:
			velocity.y = 0.0 

# Mecânica de atrito
func global_position_to_tile(pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(pos))
	
func get_friction_under_player() -> float:
	
	var tile_pos = global_position_to_tile(foot.global_position)

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
	
	# Gravidade sempre (fora do orbe)
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Movimento horizontal
	if not is_being_pulled_by_orb:
		
		# Altera o movimento quando esta no orbe gravitacional
		velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * _friction * delta)

		# Atualiza a escala/flip da animação APENAS se houver input normal
		if direction != 0:
			animation.scale.x = direction
	else:
		# Lógica de pulso/atração: move para o centro da orbita
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		
	# Animação de correr
	if not is_being_pulled_by_orb and direction != 0:
		animation.play("run")
		
	move_and_slide()
	apply_push_force()
	
	#Animações
	if not is_on_floor():
		animation.play("jump")
	elif not is_being_pulled_by_orb and direction != 0:
		animation.play("run")
	else:
		animation.play("idle")
		
# Empurrar objetos "Pushables"
func apply_push_force():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Pushables:
			var direction = -collision.get_normal()
			direction.y = 0
			collider.slide_object(direction, SPEED)
		
# A corrigir:
# Lógica da animação "run"
# Limite de velocidade dos "Pushables"
