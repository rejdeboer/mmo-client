extends PanelContainer

@onready var health_bar = %HealthBar
@onready var name_label = %Name

func setup(name: String, max_hp: float):
	name_label.text = name
	health_bar.max_value = max_hp
	health_bar.value = max_hp

func update_health(current_hp: float):
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current_hp, 0.2).set_trans(Tween.TRANS_SINE)
