extends CharacterBody3D

@onready var pivot = $Pivot
var entity_data: Entity
var target_transform = Transform3D()
var entity_template: EntityTemplate
var animation_player: AnimationPlayer


func setup(entity: Entity):
	entity_data = entity
	self.transform = entity.transform

	if entity.attributes is PlayerAttributes:
		var attributes: PlayerAttributes = entity.attributes
		# NOTE: Player asset has ID 0 for now
		entity_template = GameAssets.get_by_id(0)
	elif entity.attributes is NpcAttributes:
		var attributes: NpcAttributes = entity.attributes
		entity_template = GameAssets.get_by_id(attributes.asset_id)


func _ready():
	target_transform = self.transform
	var character = entity_template.scene.instantiate()
	pivot.add_child(character)
	character.name = "Character"
	animation_player = character.get_node("AnimationPlayer")


func _physics_process(delta):
	transform = transform.interpolate_with(target_transform, 0.2)
	if transform.origin.distance_to(target_transform.origin) >= 0.05:
		animation_player.current_animation = "Running_A"
	else:
		animation_player.current_animation = "Idle_A"


func _input_event(
	camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked on: ", entity_data.name)
			GameManager.set_target(entity_data)
			get_viewport().set_input_as_handled()
