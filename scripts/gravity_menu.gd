extends CanvasLayer
class_name GravityMenu

signal gravity_selected(preset: String)

func _ready() -> void:
	layer = 10
	_build_ui()
	visible = false

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 50)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "⚙  Controle de Gravidade"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var options := [
		["🪐  Saturno  (Pesada)", "saturn"],
		["🌍  Terra  (Normal)",   "earth"],
		["🌙  Lua  (Leve)",       "moon"],
	]
	for opt in options:
		var btn := Button.new()
		btn.text = opt[0]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.pressed.connect(_select.bind(opt[1]))
		vbox.add_child(btn)

func _select(preset: String) -> void:
	gravity_selected.emit(preset)
	close()

func open() -> void:
	visible = true

func close() -> void:
	visible = false
