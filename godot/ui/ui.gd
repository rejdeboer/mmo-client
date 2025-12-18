extends CanvasLayer

@onready var target_frame = $TargetFrame


func _ready() -> void:
	GameManager.target_changed.connect(_on_target_changed)
	target_frame.visible = false


func _on_target_changed(new_target: Entity):
	if new_target == null:
		target_frame.visible = false
	else:
		target_frame.setup(new_target.name, new_target.hp)
		target_frame.visible = true
