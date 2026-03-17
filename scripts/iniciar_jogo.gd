extends Control

func _on_fase_1_pressed() -> void:
	get_tree().change_scene_to_file("res://fases/fase1.tscn")
	
func _on_fase_2_pressed() -> void:
	pass # Replace with function body.

func _on_fase_3_pressed() -> void:
	pass # Replace with function body.

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://fases/menu.tscn")
