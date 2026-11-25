extends Node2D
signal bridge_deployed

@export var segment_scene: PackedScene:
	set(v):
		segment_scene = v
		queue_redraw()
@export_range(0.5, 30.0, 0.5)           var deploy_speed: float    = 2.0
@export_range(4, 512, 1, "suffix:px")   var segment_length_px: float = 32.0:
	set(v):
		segment_length_px = v
		queue_redraw()

@export_range(0.05, 2.0, 0.05, "suffix:s") var slide_duration: float = 0.35

@onready var som_segmento: AudioStreamPlayer2D = $SomSegmento
@onready var som_completa: AudioStreamPlayer2D = $SomBridgeCompleta

var _deployed  := false
var _deploying := false
var _segments:       Array[Node2D]  = []
var _final_positions: Array[Vector2] = []   

func _ready() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		queue_redraw()
		return
	_build_bridge()

func _process(_dt: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _notification(what: int) -> void:
	if Engine.is_editor_hint() and what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func _end_global() -> Vector2:
	var ep := get_node_or_null("EndPoint")
	if ep:
		return (ep as Node2D).global_position
	return global_position + Vector2(200.0, 0.0)

func _build_bridge() -> void:
	if not segment_scene:
		push_warning("[Bridge '%s'] Defina segment_scene no inspetor." % name)
		return
	var container: Node = get_node_or_null("Segments")
	if not container:
		push_warning("[Bridge '%s'] Crie um filho Node2D chamado 'Segments'." % name)
		return

	for s in _segments:
		if is_instance_valid(s):
			s.queue_free()
	_segments.clear()
	_final_positions.clear()          

	var start:     Vector2 = global_position
	var goal:      Vector2 = _end_global()
	var direction: Vector2 = (goal - start).normalized()
	var angle:     float   = direction.angle()
	var total:     float   = start.distance_to(goal)
	var steps:     int     = max(1, int(ceil(total / segment_length_px)))

	for i in range(steps):
		var seg = segment_scene.instantiate()
		if seg == null:
			push_error("[Bridge] Falha ao instanciar segmento %d" % i)
			continue
		container.add_child(seg)

		var final_pos := start + direction * (i * segment_length_px + segment_length_px * 0.5)
		seg.global_position = final_pos   
		seg.rotation        = angle
		seg.visible         = false
		_set_collision_disabled(seg, true)

		_segments.append(seg)
		_final_positions.append(final_pos)

func _set_collision_disabled(seg: Node2D, disabled: bool) -> void:
	for child in seg.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", disabled)

func deploy() -> void:
	if _deployed or _deploying:
		return
	if _segments.is_empty():
		_build_bridge()
	_deploying = true

	var origin := global_position
	var last_tween: Tween = null

	for i in range(_segments.size()):
		var seg       := _segments[i]
		var final_pos := _final_positions[i]

		seg.global_position = origin
		seg.visible = true

		var tw := create_tween()
		tw.set_trans(Tween.TRANS_SINE)
		tw.set_ease(Tween.EASE_OUT)
		tw.tween_property(seg, "global_position", final_pos, slide_duration)
		tw.tween_callback(_set_collision_disabled.bind(seg, false))
		last_tween = tw

		som_segmento.global_position = final_pos
		som_segmento.pitch_scale = randf_range(0.95, 1.05)
		som_segmento.play()

		await get_tree().create_timer(1.0 / deploy_speed).timeout

	if last_tween and last_tween.is_running():
		await last_tween.finished

	_deploying = false
	_deployed  = true
	som_completa.play()
	bridge_deployed.emit()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var end_local := to_local(_end_global())
	var total_len := end_local.length()
	if total_len < 1.0:
		return
	var dir:  Vector2 = end_local / total_len
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var hw:   float   = 10.0
	var hl:   float   = segment_length_px * 0.5
	var count: int    = max(1, int(ceil(total_len / segment_length_px)))
	for i in range(count):
		var center: Vector2 = dir * (i * segment_length_px + hl)
		var pts := PackedVector2Array([
			center - dir * hl + perp * hw,
			center + dir * hl + perp * hw,
			center + dir * hl - perp * hw,
			center - dir * hl - perp * hw,
		])
		draw_colored_polygon(pts, Color(0.55, 0.35, 0.10, 0.25))
		draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0.90, 0.65, 0.20, 0.85), 1.5)
	draw_dashed_line(Vector2.ZERO, end_local, Color(1, 1, 1, 0.35), 1.0, 7.0)
	draw_circle(Vector2.ZERO, 7.0, Color(0.10, 0.95, 0.35))
	draw_circle(end_local,    7.0, Color(0.95, 0.20, 0.20))
