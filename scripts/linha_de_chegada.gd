extends Area2D

@export var label_speed: Label
@export var label_record: Label
@export var label_medal: Label

var record := 0.0

func _ready():
	body_entered.connect(_on_body_entered)

	if FileAccess.file_exists("user://record.save"):
		var file = FileAccess.open("user://record.save", FileAccess.READ)
		
		if file.get_length() > 0:
			record = file.get_var()

func _on_body_entered(body):
	if body is Player:
		var speed = abs(body.velocity.x)
		var kmh = speed * 0.1
		
		show_speed(kmh)
		check_record(kmh)
		show_medal(kmh)
		
func show_speed(speed):
	var tween = create_tween()
	
	label_speed.text = "Velocidade: 0 KM/H"
	
	tween.tween_method(update_speed_label, 0, speed, 1.0)

func update_speed_label(value):
	label_speed.text = "Velocidade: " + str(round(value)) + " KM/H"
	
func check_record(speed):
	if speed > record:
		record = speed
		
		var file = FileAccess.open("user://record.save", FileAccess.WRITE)
		file.store_var(record)
		
		label_record.text = "NOVO RECORDE!"
	else:
		label_record.text = "Recorde: " + str(round(record)) + " KM/H"
		
func show_medal(speed):

	if speed > 120:
		label_medal.text = "🥇 OURO"
	elif speed > 80:
		label_medal.text = "🥈 PRATA"
	elif speed > 40:
		label_medal.text = "🥉 BRONZE"
	else:
		label_medal.text = "Sem medalha"
