extends RigidBody2D

var is_dead: bool = false
var last_checkpoint: Vector2 = Vector2.ZERO 
var pode_mover: bool = true

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var abyss_y: float = 650.0
@export var safe_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	safe_position = global_position
	last_checkpoint = safe_position


func _process(delta: float) -> void:
	
	
	if is_dead:
		self.freeze = true
	else:
		self.freeze = false
		
	if global_position.y > abyss_y:
		die()
	
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
