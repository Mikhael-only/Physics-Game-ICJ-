extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func descer():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", -90, 1.0)
