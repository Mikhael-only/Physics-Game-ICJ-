extends Area2D

@export var attraction_force: float = 500.0
@export var influence_radius: float = 90.0


var bodies_in_area: Array[Node2D] = []

func _ready() -> void:
	monitoring = true

func _is_attractable(body: Node2D) -> bool:
	return body is CharacterBody2D or body is RigidBody2D

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if _is_attractable(body) and not bodies_in_area.has(body):
		bodies_in_area.append(body)

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if _is_attractable(body):
		bodies_in_area.erase(body)

func _physics_process(delta: float) -> void:
	var orb_center: Vector2 = global_position

	for body in bodies_in_area:
		var direction_to_center: Vector2 = orb_center - body.global_position
		var distance: float = direction_to_center.length()

		var force_magnitude: float
		if distance > 1.0:
			force_magnitude = attraction_force * (1.0 / distance) * 2.0 * influence_radius
		else:
			force_magnitude = attraction_force

		var dir_normalized: Vector2 = direction_to_center.normalized()

		if body is CharacterBody2D:
			
			body.velocity += dir_normalized * force_magnitude * delta
		elif body is RigidBody2D:
			
			body.apply_central_force(dir_normalized * force_magnitude)
