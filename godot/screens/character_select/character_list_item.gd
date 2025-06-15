extends PanelContainer

signal selected(character_data)

var character_data: Dictionary

@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var level_label: Label = $HBoxContainer/LevelLabel

func set_character_data(data: Dictionary):
	self.character_data = data
	name_label.text = character_data.get("name", "Unknown")
	level_label.text = "Lv. " + str(character_data.get("level", 1))

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("selected", character_data)
		modulate = Color(0.8, 0.9, 1.0) # Highlight color

func deselect():
	modulate = Color.WHITE
