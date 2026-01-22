extends NinePatchRect

@onready var text = $text
@onready var timer = $Timer

var msg_queue: Array = [
	"Hi adventurer!", 
	"Are you busy?"
]

func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_accept"):
		show_message()
		
func show_message() -> void:
	if not timer.is_stopped():
		text.visible_characters = text.text.length()
		return
			
	if msg_queue.size() == 0:
		hide()
		return
	
	var _msg: String = msg_queue.pop_front()
	text.visible_characters = 0
	text.text = _msg
	timer.start()
	
func _on_Timer_timeout():
	if text.visible_characters == text.text.length():
		timer.stop()
	text.visible_characters += 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
