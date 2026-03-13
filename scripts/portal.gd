extends AnimatedSprite2D

var loops := 0
var max_loops := 5

func _ready():
	animation_finished.connect(_on_animation_finished)
	play("default")

func _on_animation_finished():
	loops += 1
	
	if loops < max_loops:
		play("default")
	else:
		fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()
