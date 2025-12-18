extends CharacterBody3D

var entity_data: Entity
var target_transform = Transform3D()


func setup(entity: Entity):
	entity_data = entity
	self.transform = entity.transform


func _ready():
	target_transform = self.transform


func _physics_process(delta):
	transform = transform.interpolate_with(target_transform, 0.2)
	# if transform.origin.distance_to(target_transform.origin) >= 0.05:
	# 	%Character/AnimationPlayer.current_animation = "run"
	# else:
	# 	%Character/AnimationPlayer.current_animation = "idle"


func _input_event(
	camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked on: ", entity_data.name)
			GameManager.set_target(entity_data)
			get_viewport().set_input_as_handled()
